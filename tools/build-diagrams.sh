#!/usr/bin/env bash
# Compile every assets/diagrams/*.tex into a sibling .svg using
# pdflatex + pdftocairo. Skip when the .svg is newer than its .tex.
#
# Requires:
#   - pdflatex (TeX Live)
#   - pdftocairo (poppler; `brew install poppler` on macOS)
#
# Note: dvisvgm's --pdf mode requires Ghostscript < 10.01 or mutool;
# pdftocairo has no such version dependency, so we use it.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DIA_DIR="$REPO_ROOT/assets/diagrams"
TMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TMP_ROOT"' EXIT

[ -d "$DIA_DIR" ] || { echo "no diagrams dir at $DIA_DIR"; exit 0; }

for tex in "$DIA_DIR"/*.tex; do
  [ -f "$tex" ] || continue
  base=$(basename "$tex" .tex)
  out="$DIA_DIR/$base.svg"
  # Skip if up-to-date.
  if [ -f "$out" ] && [ "$out" -nt "$tex" ]; then
    printf 'skip  %s.svg (up to date)\n' "$base"
    continue
  fi
  tmp="$TMP_ROOT/$base"
  mkdir -p "$tmp"
  cp "$tex" "$tmp/$base.tex"
  printf 'build %s.svg\n' "$base"
  (cd "$tmp" && pdflatex -interaction=batchmode "$base.tex" >/dev/null 2>&1) || {
    echo "pdflatex failed for $base; see $tmp/$base.log"; exit 1;
  }
  pdftocairo -svg "$tmp/$base.pdf" "$out" 2>/dev/null || {
    echo "pdftocairo failed for $base"; exit 1;
  }
done
