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

(cd "$REPO_ROOT" && opam exec -- dune build tools/nptel-build/bin/main.exe >/dev/null)

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

# Emit a landing page at _site/index.html so the root URL of the
# deployed site (e.g. https://<user>.github.io/<repo>/) shows a real
# page rather than a 404. Groups lectures by module, reads titles
# from each .md file's frontmatter.
emit_index() {
  local out="$REPO_ROOT/_site/index.html"
  {
    cat <<HEAD
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Functional Programming with OCaml — NPTEL</title>
  <link rel="stylesheet" href="${ASSET_ROOT}/assets/css/chapter.css">
  <style>
    .landing { max-width: 760px; margin: 2rem auto; padding: 0 1rem; }
    .landing h1 { font-family: ui-sans-serif, system-ui, sans-serif; font-size: 1.8rem; }
    .landing .module { border-top: 1px solid var(--rule); padding-top: 1rem; margin-top: 1.4rem; }
    .landing .module h2 { font-family: ui-sans-serif, system-ui, sans-serif; font-size: 1.15rem; margin: 0 0 0.4rem; }
    .landing .module-no { color: var(--muted); font-size: 0.78rem; letter-spacing: 0.04em; text-transform: uppercase; }
    .landing ul { list-style: none; padding: 0; margin: 0.5rem 0 0; }
    .landing li { margin: 0.25rem 0; }
    .landing li a { color: var(--accent); text-decoration: none; }
    .landing li a:hover { text-decoration: underline; }
    .landing .lec-no { display: inline-block; min-width: 2.4em; color: var(--muted); font-size: 0.9em; font-family: ui-monospace, monospace; }
  </style>
</head>
<body class="mode-chapter">
  <article class="landing">
    <h1>Functional Programming with OCaml</h1>
    <p>A 12-week NPTEL course. Pick a lecture below, or start at
    <a href="M01-L01-course-intro.html">Module 1, Lecture 1</a>.</p>
HEAD

    # Walk modules in order, then lectures in order. modules.txt
    # holds "<Mnn>: <title>" lines. Lecture numbers run continuously
    # across modules: M01 holds L01-L05, M02 holds L06-L11, etc.
    local modules_file="$REPO_ROOT/lectures/modules.txt"
    local running=0
    while IFS= read -r line; do
      line="${line%$'\r'}"
      case "$line" in
        ''|'#'*) continue ;;
      esac
      local mnum mtitle
      mnum="${line%%:*}"
      mtitle="${line#*: }"
      printf '    <section class="module">\n'
      printf '      <div class="module-no">%s</div>\n' "$mnum"
      printf '      <h2>%s</h2>\n' "$mtitle"
      printf '      <ul>\n'
      for src in "$REPO_ROOT"/lectures/"$mnum"-L*-*.md; do
        [ -f "$src" ] || continue
        local base ltitle
        base=$(basename "$src" .md)
        ltitle=$(awk '/^title:/ { sub(/^title: */, ""); sub(/^"/, ""); sub(/"$/, ""); print; exit }' "$src")
        running=$((running + 1))
        printf '        <li><span class="lec-no">L%02d</span> <a href="%s.html">%s</a></li>\n' \
          "$running" "$base" "$ltitle"
      done
      printf '      </ul>\n'
      printf '    </section>\n'
    done < "$modules_file"

    cat <<FOOT
  </article>
</body>
</html>
FOOT
  } > "$out"
  printf 'built _site/index.html\n'
}
emit_index
