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

# Stamp every rendered lecture with the source commit so quiz
# analytics can correlate responses with a specific version of the
# content. GitHub Actions sets GITHUB_SHA; locally we read from git.
if [ -z "${NPTEL_COMMIT_SHA:-}" ]; then
  if [ -n "${GITHUB_SHA:-}" ]; then
    NPTEL_COMMIT_SHA="$GITHUB_SHA"
  else
    NPTEL_COMMIT_SHA="$(cd "$REPO_ROOT" && git rev-parse HEAD 2>/dev/null || echo unknown)"
  fi
fi
export NPTEL_COMMIT_SHA

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
    <p style="margin-top: 3rem; font-size: 0.88rem; color: var(--muted);">
      <a href="privacy.html">Privacy &amp; data collection</a>
    </p>
  </article>
</body>
</html>
FOOT
  } > "$out"
  printf 'built _site/index.html\n'
}
emit_index

# Privacy / disclosure page. Documents what the analytics backend
# records, why, who has access, and lets the reader flip the
# opt-out toggle and delete prior responses via POST /quiz/forget.
emit_privacy() {
  local out="$REPO_ROOT/_site/privacy.html"
  cat > "$out" <<'PRIVACY'
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="quiz-api" content="https://nptel-quiz.kc-7c7.workers.dev">
  <title>Privacy — Functional Programming with OCaml</title>
  <link rel="stylesheet" href="/assets/css/chapter.css">
  <style>
    .privacy { max-width: 760px; margin: 2rem auto; padding: 0 1rem 4rem; }
    .privacy h1 { font-family: ui-sans-serif, system-ui, sans-serif; font-size: 1.8rem; }
    .privacy h2 { margin-top: 2rem; font-size: 1.2rem; }
    .privacy .toggle-row { display: flex; align-items: center; gap: 0.7rem; margin: 0.6rem 0 1.2rem; }
    .privacy button {
      padding: 0.4rem 1rem; border: 1px solid var(--accent); background: #fff;
      color: var(--accent); border-radius: 4px; cursor: pointer;
      font: inherit;
    }
    .privacy button:hover { background: var(--code-bg); }
    .privacy button.danger { border-color: #b35858; color: #b35858; }
    .privacy button.danger:hover { background: #faecec; }
    .privacy .state { color: var(--muted); font-size: 0.95em; }
    .privacy code { font-family: ui-monospace, monospace; background: var(--code-bg); padding: 0.1em 0.3em; border-radius: 3px; font-size: 0.92em; }
  </style>
</head>
<body class="mode-chapter">
  <article class="privacy">
    <p><a href="index.html">← Course landing page</a></p>
    <h1>Privacy</h1>

    <p>The site records <strong>anonymous</strong> quiz responses to
    help improve the course. This page explains exactly what is
    collected, what is not, and how to opt out or delete prior
    responses.</p>

    <h2>What we collect, per quiz answer</h2>
    <ul>
      <li>A random reader UUID, minted in your browser on first visit
        and stored locally. No name, no email, no account.</li>
      <li>The quiz identifier (page slug + auto-id like <code>q1</code>).</li>
      <li>The lecture page path (e.g. <code>/_site/M02-L01-literals.html</code>).</li>
      <li>The quiz kind: <code>mcq</code> (multiple choice) or
        <code>code</code> (code fill-in).</li>
      <li>For MCQs: which option you selected, and whether it was correct.</li>
      <li>For code quizzes: whether the assertions passed. <em>We do not
        record the code you wrote</em>, only pass or fail.</li>
      <li>A timestamp set by the server.</li>
      <li>The commit hash of the lecture source at the time, so we can
        compare answers before and after content changes.</li>
    </ul>

    <h2>What we do not collect</h2>
    <ul>
      <li>Name, email address, account information. There is no login.</li>
      <li>IP address. Cloudflare drops it at the edge before our code runs.</li>
      <li>Demographic data (age, region, prior experience).</li>
      <li>Your code from code-fill-in quizzes (only the pass/fail result).</li>
      <li>Browsing history beyond the quiz answer itself.</li>
    </ul>

    <h2>Why</h2>
    <p>The methodology mirrors the
    <a href="https://rust-book.cs.brown.edu/">Brown PLT TRPL quiz
    study</a> (Crichton et al., 2024). Aggregated answers tell us
    which questions are hardest, which wrong answers are most common,
    and where readers stop. We use that signal to revise difficult
    sections of the material, the same way the TRPL study did with
    twelve content interventions. We aim to publish anonymised
    aggregate results once the course has run for a semester.</p>

    <h2>Who has access</h2>
    <p>The course staff at IIT Madras (KC Sivaramakrishnan and
    teaching assistants). Aggregated dashboards may appear publicly;
    individual response rows do not.</p>

    <h2>Opt out</h2>
    <p>You can disable analytics at any time. The setting is stored
    in your browser, so it is per-device.</p>
    <div class="toggle-row">
      <button type="button" id="opt-toggle">Loading…</button>
      <span class="state" id="opt-state"></span>
    </div>

    <h2>Delete prior responses</h2>
    <p>If you have already answered quizzes and want every response
    associated with your browser's reader UUID to be removed from the
    database, click below. This is final and cannot be undone.</p>
    <p><button type="button" class="danger" id="forget-btn">Delete my data</button>
       <span class="state" id="forget-state"></span></p>

    <h2>Contact</h2>
    <p>Questions about this policy: KC Sivaramakrishnan, <code>kc@tarides.com</code>,
    Dept. of Computer Science and Engineering, IIT Madras.</p>

    <p style="margin-top:3rem; color: var(--muted); font-size: 0.85em;">
      Data layer: a single SQLite database (Cloudflare D1) in the
      Asia-Pacific region. Source code at
      <a href="https://github.com/fplaunchpad/ocaml_nptel/tree/main/tools/quiz-backend">github.com/fplaunchpad/ocaml_nptel/tools/quiz-backend</a>.
    </p>
  </article>

  <script>
    const API = document.querySelector('meta[name="quiz-api"]')?.content || '';
    const OPT_KEY = 'nptel-analytics-opt-out';
    const UUID_KEY = 'nptel-reader-uuid';

    function isOptOut() { return localStorage.getItem(OPT_KEY) === '1'; }
    function renderToggle() {
      const btn = document.getElementById('opt-toggle');
      const st  = document.getElementById('opt-state');
      if (isOptOut()) {
        btn.textContent = 'Re-enable analytics';
        st.textContent  = 'Analytics is currently OFF on this device.';
      } else {
        btn.textContent = 'Opt out of analytics';
        st.textContent  = 'Analytics is currently ON on this device.';
      }
    }
    document.getElementById('opt-toggle').addEventListener('click', () => {
      if (isOptOut()) localStorage.removeItem(OPT_KEY);
      else            localStorage.setItem(OPT_KEY, '1');
      renderToggle();
    });
    renderToggle();

    document.getElementById('forget-btn').addEventListener('click', async () => {
      const st = document.getElementById('forget-state');
      const uuid = localStorage.getItem(UUID_KEY);
      if (!uuid) {
        st.textContent = 'No reader UUID found on this device; nothing to delete.';
        return;
      }
      if (!confirm('Delete every quiz response associated with this device? This cannot be undone.')) return;
      st.textContent = 'Deleting…';
      try {
        const r = await fetch(API + '/quiz/forget', {
          method: 'POST',
          headers: {'Content-Type': 'application/json'},
          body: JSON.stringify({ reader_uuid: uuid }),
        });
        const j = await r.json();
        st.textContent = 'Deleted ' + (j.deleted ?? 0) + ' response(s). Local reader UUID cleared.';
        localStorage.removeItem(UUID_KEY);
      } catch (e) {
        st.textContent = 'Could not reach the server. Try again later.';
      }
    });
  </script>
</body>
</html>
PRIVACY
  printf 'built _site/privacy.html\n'
}
emit_privacy
