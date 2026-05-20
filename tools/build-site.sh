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
      &nbsp;&middot;&nbsp;
      <a href="dashboard.html">Quiz analytics dashboard</a>
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

    <p>The site can record <strong>anonymous</strong> responses to
    the inline quizzes if you opt in. This page explains exactly what
    is collected, what is not, who has access, how long we keep it,
    and how to opt in / out / export / delete at any time.</p>

    <p><strong>Default:</strong> opt-in. Nothing is sent until you
    explicitly click <em>Allow</em> in the consent banner. No login
    or account is involved either way.</p>

    <p><strong>Course audience:</strong> this material is intended
    for students 18 and older. We do not knowingly collect data
    from anyone under 18.</p>

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
    individual response rows do not. The public aggregate view lives
    at <a href="dashboard.html">dashboard.html</a> and shows only
    counts, accuracies, and option pick distributions.</p>

    <h2>Where the data lives, and cross-border transfer</h2>
    <p>Responses are stored in a single SQLite database hosted on
    <a href="https://developers.cloudflare.com/d1/">Cloudflare D1</a>,
    region-pinned to Asia-Pacific (APAC). Cloudflare may replicate
    data to other regions within its global network for resilience,
    governed by their
    <a href="https://www.cloudflare.com/cloudflare-customer-dpa/">Data
    Processing Addendum</a>. By opting in you consent to this
    cross-border transfer.</p>

    <h2>How long we keep it</h2>
    <p>Raw response rows are retained until the course completes a
    full delivery cycle (each NPTEL run is one semester) and the
    rows have been aggregated into the dashboard and any
    accompanying research dataset. After that, the raw rows are
    deleted; only the aggregate (no per-reader rows) is kept. You
    can also delete every row tied to your device immediately from
    this page using the buttons below.</p>

    <h2>Your choice on this device</h2>
    <p>Each setting is stored in your browser's localStorage, so
    it is per-device.</p>
    <div class="toggle-row">
      <button type="button" id="opt-toggle">Loading…</button>
      <span class="state" id="opt-state"></span>
    </div>

    <h2>Export your data</h2>
    <p>Download every response tied to your reader UUID, as JSON.
    Useful for transparency: see exactly what we have on you.</p>
    <p><button type="button" id="export-btn">Download my data</button>
       <span class="state" id="export-state"></span></p>

    <h2>Delete prior responses</h2>
    <p>Remove every response tied to your reader UUID. This is final
    and cannot be undone.</p>
    <p><button type="button" class="danger" id="forget-btn">Delete my data</button>
       <span class="state" id="forget-state"></span></p>

    <h2>Grievance redress</h2>
    <p>Per India's Digital Personal Data Protection Act, 2023, the
    contact for any complaint, correction request, or grievance
    related to this data collection is:</p>
    <p>KC Sivaramakrishnan,
       Assistant Professor, Dept. of Computer Science and Engineering,
       IIT Madras.<br>
       Email: <code>kc@tarides.com</code>.<br>
       Grievances are acknowledged within 7 days and addressed within
       30 days.</p>

    <h2>Source and policy version</h2>
    <p>This policy is version <strong>2026-05-20</strong>. If we
    materially change what is collected, the version bumps and the
    consent banner reappears so you can re-confirm.</p>
    <p>The Worker source is at
      <a href="https://github.com/fplaunchpad/ocaml_nptel/tree/main/tools/quiz-backend">github.com/fplaunchpad/ocaml_nptel/tools/quiz-backend</a>.
    The schema is one table; you can read it
      <a href="https://github.com/fplaunchpad/ocaml_nptel/blob/main/tools/quiz-backend/migrations/0001_init.sql">here</a>.</p>
  </article>

  <script>
    const API = document.querySelector('meta[name="quiz-api"]')?.content || '';
    const POLICY_VERSION = '2026-05-20';
    const CONSENT_KEY = 'nptel-analytics-consent';
    const CONSENT_VER_KEY = 'nptel-analytics-consent-version';
    const CONSENT_TS_KEY = 'nptel-analytics-consent-ts';
    const UUID_KEY = 'nptel-reader-uuid';

    function consentValue() {
      const v = localStorage.getItem(CONSENT_KEY);
      const ver = localStorage.getItem(CONSENT_VER_KEY);
      if ((v === 'yes' || v === 'no') && ver === POLICY_VERSION) return v;
      return 'pending';
    }
    function setConsent(v) {
      localStorage.setItem(CONSENT_KEY, v);
      localStorage.setItem(CONSENT_VER_KEY, POLICY_VERSION);
      localStorage.setItem(CONSENT_TS_KEY, new Date().toISOString());
    }
    function renderToggle() {
      const btn = document.getElementById('opt-toggle');
      const st  = document.getElementById('opt-state');
      const c = consentValue();
      if (c === 'yes') {
        btn.textContent = 'Opt out';
        const ts = localStorage.getItem(CONSENT_TS_KEY) || '';
        st.textContent  = 'Analytics is currently ON. Consent given at ' + ts + '.';
      } else if (c === 'no') {
        btn.textContent = 'Opt in';
        st.textContent  = 'Analytics is currently OFF on this device.';
      } else {
        btn.textContent = 'Opt in';
        st.textContent  = 'Analytics is currently OFF (you have not chosen yet).';
      }
    }
    document.getElementById('opt-toggle').addEventListener('click', () => {
      setConsent(consentValue() === 'yes' ? 'no' : 'yes');
      renderToggle();
    });
    renderToggle();

    document.getElementById('export-btn').addEventListener('click', async () => {
      const st = document.getElementById('export-state');
      const uuid = localStorage.getItem(UUID_KEY);
      if (!uuid) {
        st.textContent = 'No reader UUID found on this device; nothing to export.';
        return;
      }
      st.textContent = 'Fetching…';
      try {
        const r = await fetch(API + '/quiz/export', {
          method: 'POST',
          headers: {'Content-Type': 'application/json'},
          body: JSON.stringify({ reader_uuid: uuid }),
        });
        const j = await r.json();
        const blob = new Blob([JSON.stringify(j, null, 2)], { type: 'application/json' });
        const a = document.createElement('a');
        a.href = URL.createObjectURL(blob);
        a.download = 'nptel-quiz-data.json';
        a.click();
        URL.revokeObjectURL(a.href);
        st.textContent = 'Downloaded ' + (j.count ?? 0) + ' response(s).';
      } catch (e) {
        st.textContent = 'Could not reach the server. Try again later.';
      }
    });

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

# Public analytics dashboard. Renders aggregated stats from the
# Cloudflare Worker at /quiz/agg and /quiz/agg/readers. Plain-JS;
# no build step. The page only ever displays counts and option-pick
# distributions; no individual response rows are shown.
emit_dashboard() {
  local out="$REPO_ROOT/_site/dashboard.html"
  cat > "$out" <<'DASHBOARD'
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="quiz-api" content="https://nptel-quiz.kc-7c7.workers.dev">
  <title>Quiz analytics &middot; Functional Programming with OCaml</title>
  <link rel="stylesheet" href="/assets/css/chapter.css">
  <style>
    .dash { max-width: 980px; margin: 2rem auto; padding: 0 1rem 4rem; }
    .dash h1 { font-family: ui-sans-serif, system-ui, sans-serif; font-size: 1.8rem; }
    .dash h2 { margin-top: 2.2rem; font-size: 1.2rem; }
    .dash .note {
      margin: 0.8rem 0 1.4rem;
      padding: 0.6rem 0.9rem;
      background: var(--code-bg);
      border-left: 3px solid var(--accent);
      font-size: 0.92em;
      color: var(--muted);
    }
    .dash .cards {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
      gap: 0.8rem;
      margin: 0.6rem 0 1.4rem;
    }
    .dash .card {
      border: 1px solid var(--rule);
      border-radius: 4px;
      padding: 0.7rem 0.9rem;
      background: #fafafa;
    }
    .dash .card .label {
      font-size: 0.78rem;
      letter-spacing: 0.04em;
      text-transform: uppercase;
      color: var(--muted);
      font-family: ui-sans-serif, system-ui, sans-serif;
    }
    .dash .card .value {
      font-size: 1.5rem;
      font-weight: 600;
      margin-top: 0.2rem;
      font-family: ui-sans-serif, system-ui, sans-serif;
    }
    .dash table {
      width: 100%;
      border-collapse: collapse;
      font-size: 0.92em;
      font-family: ui-sans-serif, system-ui, sans-serif;
    }
    .dash th, .dash td {
      text-align: left;
      padding: 0.4rem 0.6rem;
      border-bottom: 1px solid var(--rule);
      vertical-align: middle;
    }
    .dash th {
      background: var(--code-bg);
      cursor: pointer;
      user-select: none;
      font-weight: 600;
      white-space: nowrap;
    }
    .dash th .arrow { color: var(--muted); font-size: 0.78em; margin-left: 0.2em; }
    .dash th[aria-sort="ascending"] .arrow::after { content: "\25B2"; }
    .dash th[aria-sort="descending"] .arrow::after { content: "\25BC"; }
    .dash td.num { text-align: right; font-variant-numeric: tabular-nums; }
    .dash td.code {
      font-family: ui-monospace, "JetBrains Mono", Menlo, monospace;
      font-size: 0.88em;
    }
    .dash tr.difficult td { background: #faecec; }
    .dash tr.difficult td:first-child { border-left: 3px solid #b35858; }

    /* CSS-only horizontal accuracy bar. */
    .acc-bar {
      position: relative;
      display: inline-block;
      width: 110px;
      height: 0.7rem;
      background: var(--code-bg);
      border: 1px solid var(--rule);
      border-radius: 3px;
      vertical-align: middle;
      margin-right: 0.5rem;
      overflow: hidden;
    }
    .acc-bar > span {
      display: block;
      height: 100%;
      background: var(--accent);
    }
    .acc-bar.low > span { background: #b35858; }
    .acc-bar.mid > span { background: #c4923a; }

    .dash .empty {
      padding: 2rem 1rem;
      text-align: center;
      color: var(--muted);
      border: 1px dashed var(--rule);
      border-radius: 4px;
      font-family: ui-sans-serif, system-ui, sans-serif;
    }
    .dash .err {
      padding: 0.9rem 1rem;
      border: 1px solid #c98a8a;
      background: #f8e2e2;
      border-radius: 4px;
      color: #7a2929;
      font-family: ui-sans-serif, system-ui, sans-serif;
      font-size: 0.92em;
    }
    .dash .legend {
      font-size: 0.85em;
      color: var(--muted);
      margin-top: 0.4rem;
      font-family: ui-sans-serif, system-ui, sans-serif;
    }
    .dash .legend .swatch {
      display: inline-block;
      width: 0.7em;
      height: 0.7em;
      border-radius: 2px;
      margin-right: 0.3em;
      vertical-align: -0.05em;
    }
    .dash .legend .swatch.low { background: #b35858; }
    .dash .legend .swatch.mid { background: #c4923a; }
    .dash .legend .swatch.hi  { background: var(--accent); }
    .dash .lecture-best  { color: #2e6e3a; font-weight: 600; }
    .dash .lecture-worst { color: #b35858; font-weight: 600; }
    .dash .distractor    { color: #b35858; }
    .dash .sha-pill      {
      display: inline-block; margin-left: 0.4em;
      padding: 0.05em 0.4em;
      font-family: ui-monospace, monospace; font-size: 0.78em;
      background: var(--code-bg); color: var(--muted);
      border-radius: 3px; vertical-align: 0.05em;
    }
  </style>
</head>
<body class="mode-chapter">
  <article class="dash">
    <p><a href="index.html">&larr; Course landing page</a> &middot;
       <a href="privacy.html">Privacy</a></p>
    <h1>Quiz analytics</h1>
    <p class="note">This dashboard shows only aggregated data;
      individual responses are not displayed and cannot be
      reconstructed from this view.</p>

    <div id="status" class="empty">Loading aggregated stats&hellip;</div>

    <section id="cards-section" hidden>
      <div class="cards" id="cards"></div>
    </section>

    <section id="lectures-section" hidden>
      <h2>Per-lecture summary</h2>
      <p class="legend">
        Highest aggregate accuracy:
        <span class="lecture-best" id="best-lecture">n/a</span>.
        Lowest aggregate accuracy:
        <span class="lecture-worst" id="worst-lecture">n/a</span>.
      </p>
      <table id="lectures-table">
        <thead>
          <tr>
            <th data-sort="lecture">Lecture <span class="arrow"></span></th>
            <th data-sort="num" class="num">Quizzes <span class="arrow"></span></th>
            <th data-sort="num" class="num">Attempts <span class="arrow"></span></th>
            <th data-sort="num" class="num">Avg accuracy <span class="arrow"></span></th>
          </tr>
        </thead>
        <tbody></tbody>
      </table>
    </section>

    <section id="per-quiz-section" hidden>
      <h2>Per-quiz accuracy</h2>
      <p class="legend">
        Rows where accuracy is below 30% are highlighted; these are
        TRPL-style &ldquo;difficult questions&rdquo; worth revisiting.
        <span class="swatch low"></span>&lt; 30%
        &nbsp;<span class="swatch mid"></span>30 to 70%
        &nbsp;<span class="swatch hi"></span>&gt; 70%
      </p>
      <table id="per-quiz-table">
        <thead>
          <tr>
            <th data-sort="quiz_id">Quiz <span class="arrow"></span></th>
            <th data-sort="kind">Kind <span class="arrow"></span></th>
            <th data-sort="num" class="num">Attempts <span class="arrow"></span></th>
            <th data-sort="num" class="num">Correct <span class="arrow"></span></th>
            <th data-sort="num" class="num">Accuracy <span class="arrow"></span></th>
          </tr>
        </thead>
        <tbody></tbody>
      </table>
    </section>

    <section id="distractor-section" hidden>
      <h2>MCQ top distractors</h2>
      <p class="legend">For each MCQ, the most popular <em>wrong</em>
        answer and how many readers picked it. Following Crichton et
        al., a high-pick distractor on a low-accuracy question is a
        signal that the wording is confusing.</p>
      <table id="distractor-table">
        <thead>
          <tr>
            <th data-sort="quiz_id">Quiz <span class="arrow"></span></th>
            <th data-sort="num" class="num">Accuracy <span class="arrow"></span></th>
            <th data-sort="num" class="num">Top distractor (option) <span class="arrow"></span></th>
            <th data-sort="num" class="num">Picks <span class="arrow"></span></th>
            <th data-sort="num" class="num">Share of wrong <span class="arrow"></span></th>
          </tr>
        </thead>
        <tbody></tbody>
      </table>
    </section>
  </article>

  <script>
    const API = document.querySelector('meta[name="quiz-api"]')?.content || '';

    const fmtPct = (x) => (x == null) ? 'n/a' : (Math.round(x * 1000) / 10).toFixed(1) + '%';
    const fmtInt = (x) => (x == null) ? 'n/a' : Number(x).toLocaleString();

    // Lecture slug = the page slug stripped of the [#qN] suffix.
    // quiz_id values are emitted by parse.ml as "<page>#<auto-id>",
    // where <page> is the basename of the rendered HTML. The reader
    // POSTs them including the leading "/_site/" path prefix, so we
    // strip that for a clean lecture display name.
    function lectureKey(quizId) {
      const hash = quizId.indexOf('#');
      let key = hash >= 0 ? quizId.slice(0, hash) : quizId;
      key = key.replace(/^\/?_site\//, '').replace(/^\/+/, '');
      return key;
    }
    // Pin every dashboard link to the commit_sha of the response,
    // not the current HEAD of the website. This way deleted or
    // renamed questions stay reachable: GitHub keeps every old
    // file at every old sha, so the reader sees the question text
    // exactly as it was when those responses were collected.
    // [latest_sha] comes from /quiz/agg (most recent response's
    // commit_sha for this quiz_id).
    const REPO_BLOB_BASE = 'https://github.com/fplaunchpad/ocaml_nptel/blob';
    function lectureFileFromQuizId(quizId) {
      // "/_site/M01-L02-why-fp.html#cons-immutability"
      //  -> "lectures/M01-L02-why-fp.md"
      const noSite = quizId.replace(/^\/?_site\//, '').replace(/^\/+/, '');
      const noFrag = noSite.split('#')[0];
      const noHtml = noFrag.replace(/\.html$/, '.md');
      return 'lectures/' + noHtml;
    }
    function quizLink(quizId, latestSha) {
      const cleaned = quizId.replace(/^\/?_site\//, '').replace(/^\/+/, '');
      const fileMd = lectureFileFromQuizId(quizId);
      const sha = (latestSha && latestSha.length >= 7) ? latestSha : 'main';
      const href = REPO_BLOB_BASE + '/' + encodeURIComponent(sha) + '/' + fileMd;
      const shaShort = sha === 'main' ? 'main' : sha.slice(0, 7);
      return '<a href="' + escapeHtml(href) + '" target="_blank" rel="noopener" '
           + 'title="View the lecture source at the commit these responses were collected against">'
           + escapeHtml(cleaned)
           + ' <span class="sha-pill">' + escapeHtml(shaShort) + '</span></a>';
    }

    function accClass(a) {
      if (a == null) return '';
      if (a < 0.30) return 'low';
      if (a < 0.70) return 'mid';
      return 'hi';
    }

    function accBar(a) {
      const cls = accClass(a);
      const pct = (a == null) ? 0 : Math.max(0, Math.min(1, a)) * 100;
      return '<span class="acc-bar ' + cls + '"><span style="width:' + pct + '%"></span></span>'
           + fmtPct(a);
    }

    async function load() {
      const status = document.getElementById('status');
      let agg, readersInfo;
      try {
        const r1 = await fetch(API + '/quiz/agg');
        if (!r1.ok) throw new Error('HTTP ' + r1.status);
        agg = await r1.json();
      } catch (e) {
        status.className = 'err';
        status.textContent = 'Could not reach the analytics backend: ' + (e.message || e);
        return;
      }
      // Reader count is best-effort; if the endpoint is not deployed
      // yet, fall back to "unknown" rather than blocking the page.
      try {
        const r2 = await fetch(API + '/quiz/agg/readers');
        if (r2.ok) readersInfo = await r2.json();
      } catch (_) { /* ignore */ }

      const perQuiz = agg.per_quiz || [];
      const mcqOpts = agg.mcq_options || [];

      if (perQuiz.length === 0) {
        status.className = 'empty';
        status.textContent =
          'No quiz responses yet. Once readers start answering quizzes, '
          + 'aggregate statistics will appear here.';
        return;
      }

      // Reveal the dashboard now that we know there is data.
      status.hidden = true;
      ['cards-section', 'lectures-section', 'per-quiz-section', 'distractor-section']
        .forEach((id) => { document.getElementById(id).hidden = false; });

      renderCards(perQuiz, readersInfo);
      renderLectures(perQuiz);
      renderPerQuiz(perQuiz);
      renderDistractors(perQuiz, mcqOpts);
    }

    function renderCards(perQuiz, readersInfo) {
      const totalAttempts = perQuiz.reduce((a, r) => a + (r.attempts_total || 0), 0);
      const totalCorrect  = perQuiz.reduce((a, r) => a + (r.correct_total  || 0), 0);
      const overallAcc    = totalAttempts > 0 ? totalCorrect / totalAttempts : null;
      const mcqQuizzes    = perQuiz.filter((r) => r.kind === 'mcq').length;
      const codeQuizzes   = perQuiz.filter((r) => r.kind === 'code').length;

      const cards = [
        { label: 'Total responses',  value: fmtInt(totalAttempts) },
        { label: 'Distinct readers', value: readersInfo ? fmtInt(readersInfo.readers) : 'n/a' },
        { label: 'Quizzes seen',     value: fmtInt(perQuiz.length) },
        { label: 'MCQ / code',       value: fmtInt(mcqQuizzes) + ' / ' + fmtInt(codeQuizzes) },
        { label: 'Overall accuracy', value: fmtPct(overallAcc) },
      ];
      const el = document.getElementById('cards');
      el.innerHTML = cards.map(
        (c) => '<div class="card"><div class="label">' + c.label
             + '</div><div class="value">' + c.value + '</div></div>'
      ).join('');
    }

    function renderLectures(perQuiz) {
      const by = new Map();
      for (const r of perQuiz) {
        const key = lectureKey(r.quiz_id);
        let g = by.get(key);
        if (!g) { g = { lecture: key, quizzes: 0, attempts: 0, correct: 0 }; by.set(key, g); }
        g.quizzes  += 1;
        g.attempts += r.attempts_total || 0;
        g.correct  += r.correct_total  || 0;
      }
      const rows = Array.from(by.values()).map((g) => ({
        lecture:  g.lecture,
        quizzes:  g.quizzes,
        attempts: g.attempts,
        accuracy: g.attempts > 0 ? g.correct / g.attempts : null,
      }));

      // Best / worst by aggregate accuracy, ignoring lectures with no
      // attempts. Ties are broken by attempt count (more attempts wins).
      const withData = rows.filter((r) => r.accuracy != null && r.attempts > 0);
      if (withData.length > 0) {
        const sorted = withData.slice().sort((a, b) =>
          (b.accuracy - a.accuracy) || (b.attempts - a.attempts));
        document.getElementById('best-lecture').textContent =
          sorted[0].lecture + ' (' + fmtPct(sorted[0].accuracy) + ')';
        const last = sorted[sorted.length - 1];
        document.getElementById('worst-lecture').textContent =
          last.lecture + ' (' + fmtPct(last.accuracy) + ')';
      }

      const tbody = document.querySelector('#lectures-table tbody');
      rows.sort((a, b) => a.lecture.localeCompare(b.lecture));
      tbody.innerHTML = rows.map((r) => '<tr>'
        + '<td class="code">' + escapeHtml(r.lecture) + '</td>'
        + '<td class="num">' + fmtInt(r.quizzes) + '</td>'
        + '<td class="num">' + fmtInt(r.attempts) + '</td>'
        + '<td class="num">' + accBar(r.accuracy) + '</td>'
      + '</tr>').join('');

      attachSorter(document.getElementById('lectures-table'), [
        (r) => r.cells[0].textContent,
        (r) => Number(r.cells[1].textContent.replace(/,/g, '')),
        (r) => Number(r.cells[2].textContent.replace(/,/g, '')),
        (r) => parseFloat(r.cells[3].textContent.replace('%', '')) || -1,
      ]);
    }

    function renderPerQuiz(perQuiz) {
      const rows = perQuiz.slice().sort((a, b) => a.quiz_id.localeCompare(b.quiz_id));
      const tbody = document.querySelector('#per-quiz-table tbody');
      tbody.innerHTML = rows.map((r) => {
        const difficult = (r.accuracy != null && r.accuracy < 0.30) ? ' class="difficult"' : '';
        return '<tr' + difficult + '>'
          + '<td class="code">' + quizLink(r.quiz_id, r.latest_sha) + '</td>'
          + '<td>' + escapeHtml(r.kind) + '</td>'
          + '<td class="num">' + fmtInt(r.attempts_total) + '</td>'
          + '<td class="num">' + fmtInt(r.correct_total)  + '</td>'
          + '<td class="num">' + accBar(r.accuracy) + '</td>'
        + '</tr>';
      }).join('');

      attachSorter(document.getElementById('per-quiz-table'), [
        (r) => r.cells[0].textContent,
        (r) => r.cells[1].textContent,
        (r) => Number(r.cells[2].textContent.replace(/,/g, '')),
        (r) => Number(r.cells[3].textContent.replace(/,/g, '')),
        (r) => parseFloat(r.cells[4].textContent.replace('%', '')) || -1,
      ]);
    }

    function renderDistractors(perQuiz, mcqOpts) {
      const byQuiz = new Map(perQuiz.map((r) => [r.quiz_id, r]));
      // Group option picks by quiz_id.
      const picksByQuiz = new Map();
      for (const o of mcqOpts) {
        let m = picksByQuiz.get(o.quiz_id);
        if (!m) { m = []; picksByQuiz.set(o.quiz_id, m); }
        m.push({ selected: o.selected, picks: o.picks });
      }

      const rows = [];
      for (const [quizId, picks] of picksByQuiz) {
        const meta = byQuiz.get(quizId);
        if (!meta || meta.kind !== 'mcq') continue;
        // The schema does not record which option index is canonical,
        // but every wrong selection is a distractor. Infer the correct
        // option as the one whose pick count exactly matches the
        // per-quiz [correct_total]. The remaining picks are all wrong.
        let correctIdx = null;
        for (const p of picks) {
          if (p.picks === meta.correct_total) { correctIdx = p.selected; break; }
        }
        const wrongOptions = picks.filter((p) => p.selected !== correctIdx);
        if (wrongOptions.length === 0) continue;
        wrongOptions.sort((a, b) => b.picks - a.picks);
        const top = wrongOptions[0];
        const wrongPicks = wrongOptions.reduce((a, p) => a + p.picks, 0);
        rows.push({
          quiz_id:    quizId,
          accuracy:   meta.accuracy,
          option:     top.selected,
          picks:      top.picks,
          wrongShare: wrongPicks > 0 ? top.picks / wrongPicks : null,
          latest_sha: meta.latest_sha,
        });
      }

      const section = document.getElementById('distractor-section');
      if (rows.length === 0) {
        section.hidden = true;
        return;
      }
      rows.sort((a, b) => (a.accuracy ?? 1) - (b.accuracy ?? 1));

      const tbody = document.querySelector('#distractor-table tbody');
      tbody.innerHTML = rows.map((r) => {
        const difficult = (r.accuracy != null && r.accuracy < 0.30) ? ' class="difficult"' : '';
        return '<tr' + difficult + '>'
          + '<td class="code">' + quizLink(r.quiz_id, r.latest_sha) + '</td>'
          + '<td class="num">' + accBar(r.accuracy) + '</td>'
          + '<td class="num distractor">option ' + fmtInt(r.option) + '</td>'
          + '<td class="num">' + fmtInt(r.picks) + '</td>'
          + '<td class="num">' + fmtPct(r.wrongShare) + '</td>'
        + '</tr>';
      }).join('');

      attachSorter(document.getElementById('distractor-table'), [
        (r) => r.cells[0].textContent,
        (r) => parseFloat(r.cells[1].textContent.replace('%', '')) || -1,
        (r) => Number((r.cells[2].textContent.match(/-?\d+/) || [0])[0]),
        (r) => Number(r.cells[3].textContent.replace(/,/g, '')),
        (r) => parseFloat(r.cells[4].textContent.replace('%', '')) || -1,
      ]);
    }

    // Click a column header to sort ascending; click again to flip.
    function attachSorter(table, accessors) {
      const ths = table.querySelectorAll('thead th');
      ths.forEach((th, i) => {
        th.addEventListener('click', () => {
          const tbody = table.querySelector('tbody');
          const rows  = Array.from(tbody.querySelectorAll('tr'));
          const dir   = th.getAttribute('aria-sort') === 'ascending' ? -1 : 1;
          ths.forEach((t) => t.removeAttribute('aria-sort'));
          th.setAttribute('aria-sort', dir === 1 ? 'ascending' : 'descending');
          rows.sort((a, b) => {
            const av = accessors[i](a);
            const bv = accessors[i](b);
            if (typeof av === 'number' && typeof bv === 'number') return (av - bv) * dir;
            return String(av).localeCompare(String(bv)) * dir;
          });
          rows.forEach((r) => tbody.appendChild(r));
        });
      });
    }

    function escapeHtml(s) {
      return String(s ?? '')
        .replace(/&/g, '&amp;').replace(/</g, '&lt;')
        .replace(/>/g, '&gt;').replace(/"/g, '&quot;');
    }

    load();
  </script>
</body>
</html>
DASHBOARD
  printf 'built _site/dashboard.html\n'
}
emit_dashboard
