#!/usr/bin/env bash
# Build every lectures/**/*.md into _site/<rel>/<base>.html.
# Usage: tools/build-site.sh [src.md ...]
#   With no args, walks lectures/ recursively.
#
# Env vars:
#   ASSET_ROOT   prefix used in front of /assets/ paths. Empty (default)
#                serves assets at the site root. For GitHub Pages on a
#                project repo, set to "/<repo>".
#   COPY_ASSETS  if "1", also copy assets/ into _site/assets/ so the
#                output is self-contained and deployable.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BIN="$REPO_ROOT/_build/default/tools/nptel-build/bin/main.exe"
ASSET_ROOT="${ASSET_ROOT:-}"
COPY_ASSETS="${COPY_ASSETS:-0}"

(cd "$REPO_ROOT" && opam exec --switch=5.4.0 -- dune build tools/nptel-build/bin/main.exe >/dev/null)

if [ $# -eq 0 ]; then
  # Lecture files follow the M<nn>-L<nn>-slug.md convention. Other .md
  # files under lectures/ (e.g. drafts, READMEs) are skipped.
  mapfile -d '' files < <(find "$REPO_ROOT/lectures" -name 'M*-L*-*.md' -print0 2>/dev/null)
else
  files=("$@")
fi

for src in "${files[@]}"; do
  [ -f "$src" ] || continue
  rel="${src#$REPO_ROOT/}"
  dst="$REPO_ROOT/_site/${rel%.md}.html"
  dst="${dst/lectures\//}"
  mkdir -p "$(dirname "$dst")"
  "$BIN" "$src" "$dst" "$ASSET_ROOT"
  printf 'built %s\n' "${dst#$REPO_ROOT/}"
done

# Always keep the smoke test fresh.
if [ -f "$REPO_ROOT/tools/nptel-build/test/smoke.md" ]; then
  mkdir -p "$REPO_ROOT/_site/test"
  "$BIN" "$REPO_ROOT/tools/nptel-build/test/smoke.md" \
    "$REPO_ROOT/_site/test/smoke.html" "$ASSET_ROOT"
fi

# For deploy: vendor the static assets under _site/ so the output is
# self-contained. For local preview, the http.server already serves
# /assets/ from the repo root, so we skip this.
if [ "$COPY_ASSETS" = "1" ]; then
  rm -rf "$REPO_ROOT/_site/assets"
  cp -r "$REPO_ROOT/assets" "$REPO_ROOT/_site/assets"
fi
