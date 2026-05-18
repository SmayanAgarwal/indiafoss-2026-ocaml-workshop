#!/usr/bin/env bash
# Video-analysis pipeline for the NPTEL course.
#
# For each video in playlist.txt:
#   1. yt-dlp -> video.mp4 + info.json
#   2. ffmpeg  -> audio.wav (16kHz mono)
#   3. ffmpeg  -> slides/*.png (scene-detect, fallback to 30s interval)
#   4. mlx_whisper -> transcript.json
#   5. align slides to narration -> slides_with_narration.json
#   6. emit transcript.md (readable drafting view)
#
# Every stage is idempotent: skip if its output already exists.

set -uo pipefail

# pip --user installs mlx_whisper here; PATH it.
export PATH="/Users/kc/Library/Python/3.12/bin:$PATH"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CACHE_DIR="$REPO_ROOT/_references/_video"
PLAYLIST_FILE="$SCRIPT_DIR/playlist.txt"

DL_PARALLEL="${DL_PARALLEL:-1}"  # one-by-one keeps YouTube happy
AV_PARALLEL="${AV_PARALLEL:-$(sysctl -n hw.ncpu 2>/dev/null || echo 4)}"
ASR_PARALLEL="${ASR_PARALLEL:-1}"   # bump if GPU has headroom
WHISPER_MODEL="${WHISPER_MODEL:-mlx-community/whisper-small.en-mlx}"

mkdir -p "$CACHE_DIR"

log() { printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*" >&2; }

# --- 1. Enumerate playlist into a flat list of {id, slug} ----------------------
enumerate_playlist() {
  local playlist="$1"
  log "Enumerating $playlist"
  # --flat-playlist returns one JSON object per entry; we keep id and title.
  yt-dlp --flat-playlist -J "$playlist" \
    | jq -r '
        .entries
        | to_entries[]
        | "\((.key + 1) | tostring | if length == 1 then "0" + . else . end)\t\(.value.id)\t\(.value.title)"
      '
}

# --- 2. Per-video download -----------------------------------------------------
download_one() {
  local idx="$1" vid="$2" title="$3"
  local slug
  slug=$(printf '%s' "$title" | tr '[:upper:]' '[:lower:]' \
        | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g' | cut -c1-60)
  local dir="$CACHE_DIR/${idx}-${slug}"
  mkdir -p "$dir"
  printf '%s\n' "$idx" > "$dir/.idx"
  printf '%s\n' "$vid" > "$dir/.id"

  if [ -s "$dir/video.mp4" ] && [ -s "$dir/info.json" ]; then
    log "skip download: $idx-$slug"
    return 0
  fi

  log "download:      $idx-$slug ($vid)"
  yt-dlp \
    --no-progress \
    --concurrent-fragments 8 \
    -f 'bv*+ba/best' \
    --merge-output-format mp4 \
    -o "$dir/video.%(ext)s" \
    --write-info-json \
    -- "https://www.youtube.com/watch?v=$vid" >/dev/null 2>>"$dir/yt-dlp.log"

  # yt-dlp writes info.json next to the video; normalize the name.
  if [ -f "$dir/video.info.json" ]; then
    mv "$dir/video.info.json" "$dir/info.json"
  fi
}
export -f download_one log
export CACHE_DIR

# --- 3. Audio + slides ---------------------------------------------------------
extract_audio() {
  local dir="$1"
  [ -s "$dir/video.mp4" ] || { log "no video (skip audio): $dir"; return 0; }
  [ -s "$dir/audio.wav" ] && { log "skip audio:   $dir"; return 0; }
  log "audio:        $dir"
  ffmpeg -nostdin -loglevel error -y \
    -i "$dir/video.mp4" -ac 1 -ar 16000 "$dir/audio.wav"
}
export -f extract_audio

extract_slides() {
  local dir="$1"
  [ -s "$dir/video.mp4" ] || { log "no video (skip slides): $dir"; return 0; }
  if [ -d "$dir/slides" ] && [ -n "$(ls "$dir/slides" 2>/dev/null | head -1)" ]; then
    log "skip slides:  $dir"
    return 0
  fi
  mkdir -p "$dir/slides"
  log "slides (scene): $dir"
  ffmpeg -nostdin -loglevel error -y \
    -i "$dir/video.mp4" \
    -vf "select='gt(scene,0.3)',showinfo" \
    -vsync vfr "$dir/slides/scene_%04d.png" 2>"$dir/slides/scene.log" || true

  local n
  n=$(ls "$dir/slides"/*.png 2>/dev/null | wc -l | tr -d ' ')
  if [ "${n:-0}" -lt 10 ]; then
    log "slides (interval fallback): $dir"
    rm -f "$dir/slides"/*.png
    ffmpeg -nostdin -loglevel error -y \
      -i "$dir/video.mp4" \
      -vf "fps=1/30" \
      "$dir/slides/interval_%04d.png" 2>>"$dir/slides/scene.log" || true
  fi
}
export -f extract_slides

# --- 4. Transcription ----------------------------------------------------------
transcribe() {
  local dir="$1"
  [ -s "$dir/transcript.json" ] && { log "skip whisper: $dir"; return 0; }
  [ -s "$dir/audio.wav" ] || { log "no audio (skip):  $dir"; return 0; }
  log "whisper:      $dir"
  # mlx_whisper writes <basename>.json next to the input.
  ( cd "$dir" && \
    mlx_whisper audio.wav \
      --model "$WHISPER_MODEL" \
      --output-format json \
      --output-dir . \
      --word-timestamps True \
      --language en \
      >mlx_whisper.log 2>&1 ) || true
  if [ -f "$dir/audio.json" ]; then
    mv "$dir/audio.json" "$dir/transcript.json"
  fi
}
export -f transcribe
export WHISPER_MODEL

# --- 5. Slide / narration alignment + 6. transcript.md ------------------------
emit_aligned() {
  local dir="$1"
  if [ -s "$dir/slides_with_narration.json" ] && [ -s "$dir/transcript.md" ]; then
    log "skip align:   $dir"
    return 0
  fi
  [ -s "$dir/transcript.json" ] || { log "no transcript yet: $dir"; return 0; }
  log "align:        $dir"
  python3 "$SCRIPT_DIR/align.py" "$dir"
}
export -f emit_aligned
export SCRIPT_DIR

# --- main loop -----------------------------------------------------------------
main() {
  : > "$CACHE_DIR/.queue.tsv"
  while IFS= read -r playlist; do
    [ -z "$playlist" ] && continue
    enumerate_playlist "$playlist" >> "$CACHE_DIR/.queue.tsv"
  done < "$PLAYLIST_FILE"

  log "queue: $(wc -l < "$CACHE_DIR/.queue.tsv") videos"

  # Phase 1: downloads (always serial; one-by-one keeps YouTube happy)
  while IFS=$'\t' read -r idx vid title; do
    [ -z "$vid" ] && continue
    download_one "$idx" "$vid" "$title"
  done < "$CACHE_DIR/.queue.tsv"

  # Phase 2: audio + slides in parallel across videos
  while IFS= read -r d; do
    extract_audio "$d" &
    [ "$(jobs -r | wc -l)" -ge "$AV_PARALLEL" ] && wait -n
  done < <(find "$CACHE_DIR" -mindepth 1 -maxdepth 1 -type d)
  wait
  while IFS= read -r d; do
    extract_slides "$d" &
    [ "$(jobs -r | wc -l)" -ge "$AV_PARALLEL" ] && wait -n
  done < <(find "$CACHE_DIR" -mindepth 1 -maxdepth 1 -type d)
  wait

  # Phase 3: whisper (default serial; bump ASR_PARALLEL if GPU has room)
  while IFS= read -r d; do
    transcribe "$d" &
    [ "$(jobs -r | wc -l)" -ge "$ASR_PARALLEL" ] && wait -n
  done < <(find "$CACHE_DIR" -mindepth 1 -maxdepth 1 -type d)
  wait

  # Phase 4: alignment + transcript.md
  while IFS= read -r d; do
    emit_aligned "$d" &
    [ "$(jobs -r | wc -l)" -ge "$AV_PARALLEL" ] && wait -n
  done < <(find "$CACHE_DIR" -mindepth 1 -maxdepth 1 -type d)
  wait

  log "done"
}

main "$@"
