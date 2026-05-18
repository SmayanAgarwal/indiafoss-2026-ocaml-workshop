#!/usr/bin/env python3
"""Align slide stills with whisper transcript segments.

Reads transcript.json + slides/ from the given directory and emits
slides_with_narration.json and transcript.md (a drafting-friendly
view: slide thumbnail + aligned spoken text).

Slide timestamps:
  scene_NNNN.png   -- timestamp from scene log (parsed from scene.log if available).
  interval_NNNN.png -- 1 frame per 30s starting at t=0.

If we can't recover a slide timestamp, we fall back to spreading the
slides uniformly across the audio duration.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path


def load_scene_log(slides_dir: Path) -> dict[str, float]:
    """Parse ffmpeg showinfo log for scene-detect timestamps."""
    log = slides_dir / "scene.log"
    if not log.exists():
        return {}
    times: list[float] = []
    pat = re.compile(r"pts_time:([0-9.]+)")
    for line in log.read_text(errors="replace").splitlines():
        m = pat.search(line)
        if m:
            times.append(float(m.group(1)))
    scenes = sorted(slides_dir.glob("scene_*.png"))
    return {p.name: times[i] for i, p in enumerate(scenes) if i < len(times)}


def slide_times(d: Path, duration: float) -> list[tuple[str, float]]:
    slides = sorted(d.glob("slides/*.png"))
    if not slides:
        return []
    scene_map = load_scene_log(d / "slides")
    out: list[tuple[str, float]] = []
    for s in slides:
        if s.name.startswith("interval_"):
            idx = int(s.stem.split("_")[1])
            out.append((s.name, (idx - 1) * 30.0))
        elif s.name in scene_map:
            out.append((s.name, scene_map[s.name]))
        else:
            out.append((s.name, -1.0))
    if any(t < 0 for _, t in out):
        # Uniform fallback for any missing scene timestamps.
        n = len(out)
        out = [(name, duration * i / max(1, n - 1)) for i, (name, _) in enumerate(out)]
    return out


def main(d: Path) -> None:
    tr = json.loads((d / "transcript.json").read_text())
    segments = tr.get("segments", [])
    duration = 0.0
    if segments:
        duration = max(s.get("end", 0.0) for s in segments)

    slides = slide_times(d, duration)
    if not slides:
        # No slides -> emit a single bucket containing the whole transcript.
        slides = [("__no_slides__", 0.0)]
    slide_starts = [t for _, t in slides]
    slide_ends = slide_starts[1:] + [duration if duration > 0 else float("inf")]

    aligned = []
    for (name, start), end in zip(slides, slide_ends):
        text_chunks = []
        for seg in segments:
            seg_mid = (seg["start"] + seg["end"]) / 2
            if start <= seg_mid < end:
                text_chunks.append(seg["text"].strip())
        aligned.append(
            {
                "slide": f"slides/{name}" if name != "__no_slides__" else None,
                "t_start": start,
                "t_end": end if end != float("inf") else duration,
                "text": " ".join(text_chunks).strip(),
            }
        )

    (d / "slides_with_narration.json").write_text(
        json.dumps(aligned, indent=2, ensure_ascii=False)
    )

    md_lines = [f"# {d.name}", ""]
    info_path = d / "info.json"
    if info_path.exists():
        try:
            info = json.loads(info_path.read_text())
            md_lines.append(f"**{info.get('title','(no title)')}**  ")
            md_lines.append(f"id: `{info.get('id','?')}`  ")
            md_lines.append(f"duration: {info.get('duration','?')}s  ")
            md_lines.append("")
        except Exception:
            pass

    for a in aligned:
        if a["slide"]:
            md_lines.append(f"![{a['slide']}]({a['slide']})")
        md_lines.append(f"_t = {a['t_start']:.1f}s -- {a['t_end']:.1f}s_")
        md_lines.append("")
        md_lines.append(a["text"] or "_(silence)_")
        md_lines.append("")
        md_lines.append("---")
        md_lines.append("")

    (d / "transcript.md").write_text("\n".join(md_lines))


if __name__ == "__main__":
    main(Path(sys.argv[1]))
