(* Emit a single self-contained HTML page that hosts both the chapter
   view and a reveal.js slide view of the same content. The mode is
   selected client-side by the toggle button or the [#slides] URL hash.

   Asset paths are computed relative to the lecture HTML file's location
   inside [_site/], using a single configurable depth: the number of
   path segments between the lecture file and the repo root. For
   [_site/week01-intro/L02-what-is-fp.html] the depth is 2; for
   [_site/test/smoke.html] the depth is 2 as well. We just pass
   [relative_root] as a string like ["../.."]. *)

let quiz_api_url = "https://nptel-quiz.kc-7c7.workers.dev"

let head ~asset_root ~(fm : Frontmatter.t) =
  (* [asset_root] is the prefix used in front of each asset path. For
     production we use root-relative paths like ["/assets/..."], so
     callers pass [""] and the leading slash comes from each href.
     For previewing inside a subdirectory (e.g. when assets live under
     [/_site/]), the caller can pass that prefix instead. *)
  let commit_sha =
    match Sys.getenv_opt "NPTEL_COMMIT_SHA" with
    | Some s when String.trim s <> "" -> s
    | _ -> "unknown"
  in
  (* Per-module x-ocaml runtime selection.

     M01..M10 and M12 use the vanilla x-ocaml bundle at
     [assets/x-ocaml/]. M09 (testing) additionally loads an extension
     bundle via [src-load] that adds QCheck and OUnit2 into the
     running vanilla toplevel; the bundle is produced by
     tools/build-m09-extras.sh using the patched js_of_ocaml fork and
     composes additively with the worker's Stdlib.

     M11 (OxCaml) uses an entirely different worker: the x-oxcaml
     bundle at [assets/x-oxcaml/], built against OCaml 5.2.0+ox, so
     locality / uniqueness / linearity mode syntax compiles in the
     cells. No [src-load] is needed: the OxCaml worker already has the
     mode system built into the compiler. *)
  let bundle_dir, src_load_attr =
    match fm.week with
    | Some 9 ->
        ( "x-ocaml",
          Printf.sprintf
            "\n    src-load=\"%s/assets/x-ocaml/m09-extras.js\"" asset_root )
    | Some 11 -> ("x-oxcaml", "")
    | _ -> ("x-ocaml", "")
  in
  Printf.sprintf
    {|<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
  <meta name="commit-sha" content="%s">
  <meta name="quiz-api" content="%s">
  <title>%s</title>
  <link rel="stylesheet" href="%s/assets/reveal/dist/reveal.css">
  <link rel="stylesheet" href="%s/assets/reveal/dist/theme/white.css" id="reveal-theme">
  <link rel="stylesheet" href="%s/assets/css/chapter.css">
  <link rel="stylesheet" href="%s/assets/css/slides.css">
  <!-- KaTeX for inline / display math. Auto-render walks the DOM after
       load and rewrites $...$ and \(...\) inline and $$...$$ / \[...\]
       display delimiters into rendered math. We skip <x-ocaml>, <code>,
       <pre> so OCaml source / shell output never gets math-rendered. -->
  <link rel="stylesheet"
    href="https://cdn.jsdelivr.net/npm/katex@0.16.10/dist/katex.min.css"
    crossorigin="anonymous">
  <script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.10/dist/katex.min.js"
    crossorigin="anonymous"></script>
  <script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.10/dist/contrib/auto-render.min.js"
    crossorigin="anonymous"
    onload="renderMathInDocument()"></script>
  <script>
    function renderMathInDocument() {
      if (typeof renderMathInElement !== 'function') return;
      renderMathInElement(document.body, {
        delimiters: [
          { left: '$$', right: '$$', display: true },
          { left: '\\[', right: '\\]', display: true },
          { left: '\\(', right: '\\)', display: false },
          { left: '$', right: '$', display: false }
        ],
        ignoredTags: ['script', 'noscript', 'style', 'textarea',
                      'pre', 'code', 'x-ocaml'],
        throwOnError: false
      });
    }
  </script>
  <script async
    src="%s/assets/%s/x-ocaml.js"
    src-worker="%s/assets/%s/x-ocaml.worker.js"
    x-ocamlformat="margin=60"%s></script>
</head>|}
    (Parse.html_escape commit_sha)
    (Parse.html_escape quiz_api_url)
    (Parse.html_escape (if fm.title = "" then "(untitled lecture)" else fm.title))
    asset_root asset_root asset_root asset_root
    asset_root bundle_dir asset_root bundle_dir
    src_load_attr

let header_bar ~(fm : Frontmatter.t) =
  let lecture_id =
    match fm.week, fm.lecture_no with
    | Some w, Some l -> Printf.sprintf "Module %d &middot; Lecture %d" w l
    | _ -> ""
  in
  let title = if fm.title = "" then "(untitled)" else Parse.html_escape fm.title in
  Printf.sprintf
    {|  <header class="page-header">
    <button class="sidebar-collapse chapter-only" type="button" title="Show or hide the course outline" aria-label="Toggle course outline">&#9776;</button>
    <a class="home-link" href="index.html" title="Course landing page" aria-label="Course landing page">&#x2302;</a>
    <div class="lecture-meta">%s</div>
    <h1 class="lecture-title">%s</h1>
    <div class="cell-controls">
      <button class="run-up-to-here" type="button" title="Run all cells up to (and including) the current slide / cursor">Run &uarr; here</button>
      <button class="run-all" type="button" title="Run every cell on the page in order">Run all</button>
      <button class="clear-all" type="button" title="Clear outputs of every cell">Clear outputs</button>
      <button class="reset-all" type="button" title="Restore every cell to its source from the markdown file">Reset all cells</button>
    </div>
    <button class="mode-toggle" type="button" aria-label="Toggle slide mode">
      <span class="when-chapter">Slides &rarr;</span>
      <span class="when-slides">&larr; Chapter</span>
    </button>
  </header>|}
    lecture_id title

let footer_meta ~(fm : Frontmatter.t) =
  let buf = Buffer.create 256 in
  let line label value =
    if value <> "" then
      Buffer.add_string buf
        (Printf.sprintf
           {|    <div class="meta-line"><span class="meta-label">%s</span> %s</div>|}
           label value)
  in
  Buffer.add_string buf "  <footer class=\"chapter-only lecture-meta-footer\">\n";
  line "Concepts:" (String.concat ", " fm.concepts);
  line "Keywords:" (String.concat ", " fm.keywords);
  (match fm.activity_question with
   | Some q -> line "Activity:" (Parse.html_escape q)
   | None -> ());
  (match fm.think_about_this with
   | Some q -> line "Think about this:" (Parse.html_escape q)
   | None -> ());
  if fm.reading <> [] then begin
    Buffer.add_string buf "    <div class=\"meta-line\"><span class=\"meta-label\">Reading:</span><ul>\n";
    List.iter
      (fun (r : Frontmatter.reading) ->
        Buffer.add_string buf
          (Printf.sprintf
             "      <li><a href=\"%s\">%s</a></li>\n"
             (Parse.html_escape r.url) (Parse.html_escape r.title)))
      fm.reading;
    Buffer.add_string buf "    </ul></div>\n"
  end;
  Buffer.add_string buf
    "    <div class=\"meta-line\"><a href=\"privacy.html\">Privacy &amp; data collection</a></div>\n";
  Buffer.add_string buf "  </footer>\n";
  Buffer.contents buf

let runtime_script ~asset_root =
  Printf.sprintf
    {|  <script type="module">
    import Reveal from '%s/assets/reveal/dist/reveal.esm.js';

    const body = document.body;
    const modeBtn = document.querySelector('.mode-toggle');
    let reveal = null;

    function isSlideMode() {
      return location.hash === '#slides';
    }

    // Record each slide section's original chapter-view position so we
    // can move it back when leaving slide mode.
    const slideAnchors = Array.from(document.querySelectorAll('section[data-slide]'))
      .map(node => ({ node, parent: node.parentNode, next: node.nextSibling }));

    function moveSlidesIntoReveal() {
      const wrap = document.querySelector('.reveal .slides');
      if (!wrap) return;
      for (const { node } of slideAnchors) wrap.appendChild(node);
    }
    function restoreSlidesToChapter() {
      for (const { node, parent, next } of slideAnchors) {
        parent.insertBefore(node, next);
      }
      // Undo styles reveal.js applies to html/body. They lock scrolling
      // (overflow:hidden + position:fixed via the .reveal-viewport rule)
      // and persist after our wrapper is hidden.
      document.documentElement.classList.remove('reveal-full-page');
      document.body.classList.remove('reveal-viewport');
      for (const v of ['--slide-width', '--slide-height', '--slide-scale',
                       '--viewport-width', '--viewport-height']) {
        document.body.style.removeProperty(v);
      }
    }

    function allCells() {
      return Array.from(document.querySelectorAll('x-ocaml'));
    }

    // Hide slide area until x-ocaml has finished reflowing each
    // cell. The cell starts at its plain-text height, briefly
    // shrinks, then grows when CodeMirror takes over -- ~100px of
    // motion roughly 250-400ms after page load. We don't get a
    // reliable "ready" signal from x-ocaml, so we wait for cell
    // heights to be unchanged across [quietMs] AND at least
    // [minWaitMs] of elapsed time has passed (so the initial-stable
    // phase before CodeMirror takes over does not count as settled).
    // Find the cells on whichever slide we are about to land on
    // (the saved one from sessionStorage, or slide 0 by default).
    // Cells on other slides can reflow without the user noticing.
    function cellsOnTargetSlide() {
      let targetSection = null;
      try {
        const saved = sessionStorage.getItem('nptel-slide:' + location.pathname);
        if (saved) {
          const { h } = JSON.parse(saved);
          const sections = document.querySelectorAll('section[data-slide]');
          if (typeof h === 'number' && sections[h]) targetSection = sections[h];
        }
      } catch (_) {}
      if (!targetSection) {
        targetSection = document.querySelector('section[data-slide]');
      }
      return targetSection
        ? Array.from(targetSection.querySelectorAll('x-ocaml'))
        : [];
    }

    function waitForCellsToSettle() {
      const cells = cellsOnTargetSlide();
      // No cells on the target slide -> nothing can reflow there,
      // fade in immediately.
      if (cells.length === 0) {
        document.body.classList.remove('slides-loading');
        return;
      }
      const quietMs = 180;
      const minWaitMs = 500;
      const failsafeMs = 2000;
      const startedAt = Date.now();
      let quietTimer = null;
      let done = false;
      const finish = () => {
        if (done) return;
        done = true;
        clearTimeout(quietTimer);
        clearTimeout(failsafe);
        obs.disconnect();
        document.body.classList.remove('slides-loading');
        if (reveal) { reveal.sync(); reveal.layout(); }
      };
      const armQuiet = () => {
        clearTimeout(quietTimer);
        quietTimer = setTimeout(() => {
          const elapsed = Date.now() - startedAt;
          if (elapsed >= minWaitMs) finish();
          else quietTimer = setTimeout(armQuiet, minWaitMs - elapsed);
        }, quietMs);
      };
      const obs = new ResizeObserver(armQuiet);
      for (const c of cells) obs.observe(c);
      armQuiet();
      const failsafe = setTimeout(finish, failsafeMs);
    }

    // Click the cell's shadow-DOM "Run" button. x-ocaml's internal chain
    // automatically runs predecessors that aren't Run_ok yet.
    function clickRun(cell) {
      const btn = cell.shadowRoot?.querySelector('.run_btn button');
      if (btn) btn.click();
    }

    function runAll() {
      const cells = allCells();
      if (cells.length === 0) return;
      // Triggering Run on the last cell cascades upward.
      clickRun(cells[cells.length - 1]);
    }

    // "Run up to here": in slide mode "here" = last cell within or before
    // the current slide. In chapter mode it's the last cell whose top
    // is at or above the viewport center.
    function runUpToHere() {
      const cells = allCells();
      if (cells.length === 0) return;
      let target = cells[cells.length - 1];
      if (isSlideMode() && reveal) {
        const idx = reveal.getIndices();
        const sections = reveal.getSlides();
        const cur = sections[idx.h];
        // Pick the last cell whose section index is <= current.
        const eligible = cells.filter(c => {
          const sec = c.closest('section[data-slide]');
          if (!sec) return true; // outside-slide init cells always eligible
          return sections.indexOf(sec) <= sections.indexOf(cur);
        });
        if (eligible.length) target = eligible[eligible.length - 1];
      } else {
        const mid = window.innerHeight / 2;
        const eligible = cells.filter(c => c.getBoundingClientRect().top <= mid);
        if (eligible.length) target = eligible[eligible.length - 1];
      }
      clickRun(target);
    }

    // Clear by retriggering the cell's MutationObserver: set textContent
    // to its current value, which calls set_source_from_html ->
    // invalidate_from -> Editor.clear (drops all rendered messages).
    function clearAll() {
      for (const c of allCells()) {
        const txt = c.textContent;
        // Force a mutation: clear then restore. Two passes ensures the
        // observer fires even if it would dedupe identical content.
        c.textContent = '';
        c.textContent = txt;
      }
    }

    // ---------- Per-cell edit persistence via localStorage ----------
    // Key: nptel-cell:<pathname>#<cellIndex>. We track the index by
    // position among <x-ocaml> elements at load. Edits are saved with
    // a small debounce on every CodeMirror mutation; reset clears the
    // entry; identical-to-source content is also cleared so we never
    // store useless duplicates.
    const STORAGE_PREFIX = 'nptel-cell:' + location.pathname + '#';
    const storageKey = i => STORAGE_PREFIX + i;
    function cellIndex(cell) { return allCells().indexOf(cell); }
    // Read the editor's typed source by collecting [.cm-line] text only,
    // so output widgets that x-ocaml injects into the editor are not
    // mistaken for user input.
    function cellEditorText(cell) {
      const lines = cell.shadowRoot?.querySelectorAll('.cm-line');
      if (!lines || lines.length === 0) return null;
      return Array.from(lines).map(l => l.textContent).join('\n');
    }
    function dirtyButton(cell) {
      // Reset button sits inside the [.cell-wrap] that wraps the cell.
      const wrap = cell.parentElement;
      return wrap?.classList?.contains('cell-wrap')
        ? wrap.querySelector('.reset-cell')
        : null;
    }
    function persistCell(cell) {
      const idx = cellIndex(cell);
      const src = cell.getAttribute('data-source') ?? '';
      const cur = cellEditorText(cell);
      if (cur == null) return;
      const btn = dirtyButton(cell);
      if (cur.trim() === src.trim()) {
        localStorage.removeItem(storageKey(idx));
        btn?.classList.remove('dirty');
      } else {
        localStorage.setItem(storageKey(idx), cur);
        btn?.classList.add('dirty');
      }
    }
    const persistTimers = new Map();
    const pendingCells = new Set();
    function schedulePersist(cell) {
      pendingCells.add(cell);
      clearTimeout(persistTimers.get(cell));
      persistTimers.set(cell, setTimeout(() => {
        persistCell(cell);
        pendingCells.delete(cell);
        persistTimers.delete(cell);
      }, 400));
    }
    function flushPendingPersists() {
      for (const cell of pendingCells) {
        clearTimeout(persistTimers.get(cell));
        persistCell(cell);
      }
      pendingCells.clear();
      persistTimers.clear();
    }
    function watchCellForEdits(cell) {
      // Use [input] events on the editor's contenteditable surface
      // rather than a MutationObserver: [input] fires only on user
      // typing, not on programmatic DOM changes from output widgets.
      // This avoids two failure modes: saving widget text as "source",
      // and looping when x-ocaml re-renders the editor after persist.
      const ed = cell.shadowRoot?.querySelector('.cm-content');
      if (!ed) return;
      ed.addEventListener('input', () => {
        // Mark dirty immediately for instant visual feedback; the
        // actual localStorage write is debounced.
        dirtyButton(cell)?.classList.add('dirty');
        schedulePersist(cell);
      });
    }
    // Flush any pending debounced writes when the page is being
    // hidden or unloaded, so a quick Cmd+R after typing doesn't lose
    // the edit. [pagehide] fires more reliably than [beforeunload]
    // on mobile and bfcache transitions.
    window.addEventListener('pagehide', flushPendingPersists);
    document.addEventListener('visibilitychange', () => {
      if (document.visibilityState === 'hidden') flushPendingPersists();
    });
    function restorePersistedCells() {
      for (const cell of allCells()) {
        const saved = localStorage.getItem(storageKey(cellIndex(cell)));
        if (saved !== null && saved !== cell.getAttribute('data-source')) {
          cell.textContent = saved;
          dirtyButton(cell)?.classList.add('dirty');
        }
      }
    }

    // Restore a cell to the source it was emitted with (carried on the
    // [data-source] attribute). The MutationObserver picks up the
    // textContent change and re-syncs the editor. Also clears the
    // persisted edit, if any.
    function resetCell(cell) {
      const src = cell.getAttribute('data-source');
      if (src === null) return;
      cell.textContent = src;
      localStorage.removeItem(storageKey(cellIndex(cell)));
      dirtyButton(cell)?.classList.remove('dirty');
    }
    function resetAll() {
      for (const c of allCells()) resetCell(c);
    }

    // Wrap each cell in a [.cell-wrap] div and add the reset (↺)
    // button inside that wrapper. The wrapper has position:relative;
    // the reset button has position:absolute at top-right, just left
    // of the Run button (which lives in the cell's shadow DOM).
    function injectResetButtons() {
      for (const cell of allCells()) {
        if (cell.parentElement?.classList?.contains('cell-wrap')) continue;
        // Hidden quiz-test cells don't get a wrap+reset: there's no
        // point resetting a fixed test, and the absolutely-positioned
        // reset button would otherwise float beneath the quiz.
        if (cell.hasAttribute('data-quiz-test')) continue;
        const wrap = document.createElement('div');
        wrap.className = 'cell-wrap';
        cell.parentNode.insertBefore(wrap, cell);
        wrap.appendChild(cell);
        const btn = document.createElement('button');
        btn.type = 'button';
        btn.className = 'reset-cell';
        btn.title = 'Reset this cell to its source';
        btn.textContent = '↺';
        btn.addEventListener('click', () => resetCell(cell));
        wrap.appendChild(btn);
      }
    }
    injectResetButtons();

    // After x-ocaml upgrades each cell (Run button appears in shadow),
    // wire persistence and restore any saved edits.
    // x-ocaml warms up its worker by auto-evaluating the FIRST
    // cell on the page once its runtime is ready. That auto-eval
    // happens AFTER our initial clearAll(), so the first cell can
    // show stale-looking output on a fresh page load. To suppress
    // it without interfering with anything else, we watch only the
    // first cell's shadow DOM for new output, and clear it once if
    // it appears before the reader has interacted with any cell.
    let userInteracted = false;
    function watchRunButton(cell) {
      const btn = cell.shadowRoot?.querySelector('.run_btn button');
      if (!btn) return;
      btn.addEventListener('click', () => { userInteracted = true; });
    }
    function suppressFirstCellAutoWarmup() {
      const first = allCells()[0];
      if (!first) return;
      const sr = first.shadowRoot;
      if (!sr) return;
      let cleared = false;
      const obs = new MutationObserver(() => {
        if (cleared) return;
        if (userInteracted) { obs.disconnect(); return; }
        const hasOutput = sr.querySelector(
          '.caml_meta, .caml_stdout, .caml_stderr, .caml_html');
        if (hasOutput) {
          // x-ocaml's auto-warmup output. Clear once.
          const txt = first.textContent;
          first.textContent = '';
          first.textContent = txt;
          cleared = true;
          obs.disconnect();
        }
      });
      obs.observe(sr, { childList: true, subtree: true });
      // Safety: stop watching after 10s regardless. x-ocaml's
      // warmup is much faster than this; if it hasn't fired by then
      // it probably will not.
      setTimeout(() => obs.disconnect(), 10000);
    }

    async function whenCellsReady() {
      while (true) {
        const ready = allCells().every(c => c.shadowRoot?.querySelector('.cm-content'));
        if (ready) break;
        await new Promise(r => setTimeout(r, 100));
      }
      restorePersistedCells();
      for (const c of allCells()) {
        watchCellForEdits(c);
        watchRunButton(c);
      }
      // Wipe any stale output left over from previous sessions.
      clearAll();
      // x-ocaml may then auto-warm the first cell; suppress that.
      suppressFirstCellAutoWarmup();
      // Code quizzes can now find the test cell's shadow Run button.
      setupCodeQuizzes();
    }
    whenCellsReady();

    document.querySelector('.run-all')?.addEventListener('click', runAll);
    document.querySelector('.run-up-to-here')?.addEventListener('click', runUpToHere);
    document.querySelector('.clear-all')?.addEventListener('click', clearAll);
    document.querySelector('.reset-all')?.addEventListener('click', resetAll);

    // ---------- Quiz analytics (anonymous, opt-in) ----------
    // Default: NO data is sent until the reader explicitly opts in
    // via the consent banner on first visit. Following Crichton et
    // al.'s methodology in the TRPL inline-quiz study (which used
    // opt-in consent and still collected 62k+ responses), we ask
    // up front and respect the answer. The opt-in choice is stored
    // in localStorage as [nptel-analytics-consent] = "yes" | "no";
    // any other value (including missing) is treated as "not yet
    // decided" and reportQuiz() is a no-op.
    //
    // The privacy page (privacy.html) lets the reader flip the
    // choice at any time, export everything we have for their
    // UUID, or delete it all.
    //
    // POLICY_VERSION bumps if we materially change what is
    // collected; readers re-consent at the next bump.
    const POLICY_VERSION = '2026-05-20';

    const QUIZ_API = document.querySelector(
      'meta[name="quiz-api"]')?.getAttribute('content') || '';
    const COMMIT_SHA = document.querySelector(
      'meta[name="commit-sha"]')?.getAttribute('content') || '';

    function analyticsConsent() {
      if (!QUIZ_API) return 'no-api';
      const v = localStorage.getItem('nptel-analytics-consent');
      const at = localStorage.getItem('nptel-analytics-consent-version');
      if (v !== 'yes' && v !== 'no') return 'pending';
      if (at !== POLICY_VERSION) return 'pending';
      return v;
    }
    function setConsent(v) {
      try {
        localStorage.setItem('nptel-analytics-consent', v);
        localStorage.setItem('nptel-analytics-consent-version', POLICY_VERSION);
        localStorage.setItem('nptel-analytics-consent-ts', new Date().toISOString());
      } catch (_) {}
    }
    function readerUuid() {
      let id = localStorage.getItem('nptel-reader-uuid');
      if (!id) {
        id = (crypto?.randomUUID?.() ?? Math.random().toString(36).slice(2));
        localStorage.setItem('nptel-reader-uuid', id);
      }
      return id;
    }
    function reportQuiz(payload) {
      // Opt-in: only post when the reader has explicitly said yes
      // for the current policy version.
      if (analyticsConsent() !== 'yes') return;
      try {
        fetch(QUIZ_API + '/quiz', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            reader_uuid: readerUuid(),
            commit_sha: COMMIT_SHA,
            page: location.pathname,
            ...payload,
          }),
          keepalive: true,
        }).catch(() => {});
      } catch (_) {}
    }

    // First-visit consent banner (opt-in). Stays visible until the
    // reader explicitly picks Allow or Decline; can be summoned
    // again from the privacy page if dismissed accidentally.
    // Bypassed entirely if the page has no quiz-api configured.
    function showConsentIfPending() {
      if (analyticsConsent() !== 'pending') return;
      const banner = document.createElement('div');
      banner.className = 'privacy-banner';
      banner.innerHTML =
        '<p><strong>Help improve this course?</strong></p>' +
        '<p>With your consent, the site records <strong>anonymous</strong> ' +
        'responses to the inline quizzes so we can see which questions ' +
        'are hardest and revise the surrounding material. No name, ' +
        'no email, no IP address. ' +
        '<a href="privacy.html">What we collect</a>.</p>' +
        '<div class="privacy-actions">' +
        '<button type="button" class="privacy-allow">Allow</button> ' +
        '<button type="button" class="privacy-decline">Not now</button>' +
        '</div>';
      document.body.appendChild(banner);
      banner.querySelector('.privacy-allow')?.addEventListener('click', () => {
        setConsent('yes'); banner.remove();
      });
      banner.querySelector('.privacy-decline')?.addEventListener('click', () => {
        setConsent('no'); banner.remove();
      });
    }
    showConsentIfPending();

    // ---------- Inline quizzes ----------
    // Two kinds: [.quiz-mcq] and [.quiz-code]. Authored as
    // [:::quiz mcq] / [:::quiz code] fenced divs; the build emits the
    // wrapper [.quiz] div, CommonMark renders the body. The runtime
    // here turns the rendered body into an interactive widget. State
    // persists in localStorage under [nptel-quiz:<path>#<id>].
    const QUIZ_PREFIX = 'nptel-quiz:' + location.pathname + '#';

    // MCQ: GFM task lists give us [<li><input type="checkbox" [checked] disabled> ...]
    // We strip the checkboxes, build radio inputs in their place, and
    // reveal the explanation block (everything after the [<ul>]) on
    // selection. Correctness is decided by which option carried the
    // [checked] attribute in the source.
    function setupMcqQuiz(quiz) {
      const id = quiz.dataset.quizId;
      const ul = quiz.querySelector('ul');
      if (!ul) return;
      const items = Array.from(ul.querySelectorAll(':scope > li'));
      if (items.length === 0) return;
      const fieldset = document.createElement('fieldset');
      fieldset.className = 'quiz-choices';
      items.forEach((li, idx) => {
        const cb = li.querySelector('input[type="checkbox"]');
        const isCorrect = !!cb && cb.hasAttribute('checked');
        cb?.remove();
        const label = document.createElement('label');
        label.className = 'quiz-choice';
        const radio = document.createElement('input');
        radio.type = 'radio';
        radio.name = 'quiz-' + id;
        radio.value = String(idx);
        if (isCorrect) radio.dataset.correct = 'true';
        label.appendChild(radio);
        const text = document.createElement('span');
        text.className = 'quiz-choice-text';
        text.innerHTML = li.innerHTML.trim();
        label.appendChild(text);
        fieldset.appendChild(label);
      });
      // Collect everything after the <ul> as the explanation.
      const exp = document.createElement('div');
      exp.className = 'quiz-explanation';
      let n = ul.nextSibling;
      while (n) {
        const next = n.nextSibling;
        exp.appendChild(n);
        n = next;
      }
      ul.replaceWith(fieldset);
      quiz.appendChild(exp);

      function applySelection(idx) {
        const radios = fieldset.querySelectorAll('input[type="radio"]');
        if (idx == null || !radios[idx]) return false;
        radios[idx].checked = true;
        const isCorrect = radios[idx].dataset.correct === 'true';
        fieldset.querySelectorAll('.quiz-choice').forEach((label, i) => {
          const r = label.querySelector('input');
          label.classList.toggle('selected', i === idx);
          label.classList.toggle('correct', r.dataset.correct === 'true');
          label.classList.toggle('wrong', i === idx && !isCorrect);
        });
        quiz.classList.add('answered');
        quiz.classList.toggle('quiz-correct', isCorrect);
        return isCorrect;
      }
      fieldset.addEventListener('change', e => {
        if (e.target.type !== 'radio') return;
        const idx = parseInt(e.target.value);
        const isCorrect = applySelection(idx);
        try {
          localStorage.setItem(QUIZ_PREFIX + id,
            JSON.stringify({ kind: 'mcq', selected: idx, correct: isCorrect }));
        } catch (_) {}
        const line = parseInt(quiz.dataset.quizLine || '', 10);
        reportQuiz({
          quiz_id: location.pathname + '#' + id,
          kind: 'mcq',
          selected: idx,
          correct: isCorrect,
          line: Number.isFinite(line) ? line : null,
        });
      });
      // Restore prior attempt.
      try {
        const saved = localStorage.getItem(QUIZ_PREFIX + id);
        if (saved) {
          const { selected } = JSON.parse(saved);
          applySelection(selected);
        }
      } catch (_) {}
    }

    // Code quiz: visible <x-ocaml> (student cell) + hidden
    // <x-ocaml data-quiz-test> (assert block). We add a Check button
    // and a "Show tests" disclosure. Check clicks the test cell's
    // shadow Run button; x-ocaml's chaining runs the student cell
    // first as a predecessor. We poll the test cell's shadow DOM
    // for the success print or an exception.
    function setupCodeQuiz(quiz) {
      const id = quiz.dataset.quizId;
      const cells = Array.from(quiz.querySelectorAll('x-ocaml'));
      const testCell = cells.find(c => c.hasAttribute('data-quiz-test'));
      const studentCell = cells.find(c => c !== testCell);
      if (!studentCell || !testCell) return;
      if (quiz.querySelector('.quiz-controls')) return;  // already set up

      const controls = document.createElement('div');
      controls.className = 'quiz-controls';
      const checkBtn = document.createElement('button');
      checkBtn.type = 'button';
      checkBtn.className = 'quiz-check';
      checkBtn.textContent = 'Check';
      const showBtn = document.createElement('button');
      showBtn.type = 'button';
      showBtn.className = 'quiz-show-tests';
      showBtn.textContent = '▸ Show tests';
      const status = document.createElement('span');
      status.className = 'quiz-status';
      controls.append(checkBtn, showBtn, status);
      // Place controls after the student cell's wrapper.
      const wrap = studentCell.closest('.cell-wrap') || studentCell;
      wrap.parentNode.insertBefore(controls, wrap.nextSibling);

      function clickRun(cell) {
        const btn = cell.shadowRoot?.querySelector('.run_btn button');
        if (btn) btn.click();
      }
      function readState() {
        // Look at x-ocaml's OUTPUT panes only, not the source. The
        // editor's [.cm-content] contains the source text verbatim,
        // which would trivially match "all tests passed" before the
        // cell even ran. x-ocaml renders output into separate
        // [.caml_stdout], [.caml_stderr], and [.caml_meta] elements.
        const sr = testCell.shadowRoot;
        if (!sr) return 'pending';
        const out = Array.from(
          sr.querySelectorAll('.caml_stdout, .caml_stderr, .caml_meta')
        ).map(e => e.textContent || '').join('\n');
        if (!out) return 'pending';
        if (/Error|Exception|Failure|Assertion/i.test(out)) return 'fail';
        if (/all tests pass/i.test(out)) return 'pass';
        return 'pending';
      }
      function setShowTests(show) {
        quiz.classList.toggle('show-tests', show);
        showBtn.textContent = show ? '▾ Hide tests' : '▸ Show tests';
      }
      showBtn.addEventListener('click', () => {
        setShowTests(!quiz.classList.contains('show-tests'));
      });
      checkBtn.addEventListener('click', () => {
        status.textContent = 'Running…';
        status.className = 'quiz-status running';
        clickRun(testCell);
        let tries = 0;
        const tick = setInterval(() => {
          tries++;
          const s = readState();
          if (s !== 'pending' || tries > 80) {
            clearInterval(tick);
            if (s === 'pass') {
              status.textContent = '✓ All tests pass';
              status.className = 'quiz-status pass';
              quiz.classList.add('answered', 'quiz-correct');
              try {
                localStorage.setItem(QUIZ_PREFIX + id,
                  JSON.stringify({ kind: 'code', passed: true }));
              } catch (_) {}
              {
                const line = parseInt(quiz.dataset.quizLine || '', 10);
                reportQuiz({
                  quiz_id: location.pathname + '#' + id,
                  kind: 'code', passed: true, correct: true,
                  line: Number.isFinite(line) ? line : null,
                });
              }
            } else if (s === 'fail') {
              status.textContent = '✗ Some assertions failed';
              status.className = 'quiz-status fail';
              quiz.classList.remove('quiz-correct');
              quiz.classList.add('answered');
              // Auto-reveal tests so the student can see what failed.
              setShowTests(true);
              try {
                localStorage.setItem(QUIZ_PREFIX + id,
                  JSON.stringify({ kind: 'code', passed: false }));
              } catch (_) {}
              {
                const line = parseInt(quiz.dataset.quizLine || '', 10);
                reportQuiz({
                  quiz_id: location.pathname + '#' + id,
                  kind: 'code', passed: false, correct: false,
                  line: Number.isFinite(line) ? line : null,
                });
              }
            } else {
              status.textContent = 'Timed out';
              status.className = 'quiz-status fail';
            }
          }
        }, 200);
      });
      // Restore prior result.
      try {
        const saved = localStorage.getItem(QUIZ_PREFIX + id);
        if (saved) {
          const { passed } = JSON.parse(saved);
          if (passed) {
            status.textContent = '✓ Passed previously';
            status.className = 'quiz-status pass';
            quiz.classList.add('answered', 'quiz-correct');
          }
        }
      } catch (_) {}
    }

    // ---------- Heading permalinks ----------
    // Each h2/h3/h4 inside the chapter body gets a slug-id and a
    // hover-visible "permalink" anchor, so readers can deep-link
    // to a section. Slugs are derived from heading text in the
    // standard lowercase-dashed convention.
    function slugify(s) {
      return (s || '').toLowerCase()
        .replace(/[^a-z0-9\s-]/g, '')
        .replace(/\s+/g, '-')
        .replace(/-+/g, '-')
        .replace(/^-+|-+$/g, '')
        .slice(0, 80);
    }
    function setupHeadingAnchors() {
      const seen = Object.create(null);
      const headings = document.querySelectorAll(
        '.chapter h2, .chapter h3, .chapter h4');
      for (const h of headings) {
        // Strip any existing permalink we may have already added,
        // so it doesn't end up in the slug source.
        const old = h.querySelector('.permalink');
        if (old) old.remove();
        let id = h.id || slugify(h.textContent);
        if (!id) continue;
        // Collision suffix if two headings hash to the same slug.
        if (seen[id]) {
          let i = 2;
          while (seen[id + '-' + i]) i++;
          id = id + '-' + i;
        }
        seen[id] = true;
        h.id = id;
        const a = document.createElement('a');
        a.className = 'permalink';
        a.href = '#' + id;
        a.textContent = '¶';
        a.setAttribute('aria-label', 'Permalink to ' + h.textContent.trim());
        a.setAttribute('title', 'Copy link to this section');
        h.appendChild(a);
      }
    }
    setupHeadingAnchors();

    function setupMcqQuizzes() {
      document.querySelectorAll('.quiz-mcq').forEach(setupMcqQuiz);
    }
    function setupCodeQuizzes() {
      document.querySelectorAll('.quiz-code').forEach(setupCodeQuiz);
    }
    setupMcqQuizzes();
    // Code quizzes need the test cell's shadow Run button to exist;
    // setupCodeQuizzes is therefore deferred until cells are ready
    // (see [whenCellsReady] below).

    // Sidebar collapse, with persistence across pages.
    const SIDEBAR_KEY = 'nptel-sidebar-hidden';
    function applySidebarHidden(hidden) {
      document.body.classList.toggle('sidebar-hidden', hidden);
    }
    applySidebarHidden(localStorage.getItem(SIDEBAR_KEY) === '1');
    function toggleSidebar() {
      const hidden = !document.body.classList.contains('sidebar-hidden');
      applySidebarHidden(hidden);
      localStorage.setItem(SIDEBAR_KEY, hidden ? '1' : '0');
    }
    document.querySelector('.sidebar-collapse')?.addEventListener('click', toggleSidebar);

    function syncMode() {
      const slide = isSlideMode();
      body.classList.toggle('mode-slides', slide);
      body.classList.toggle('mode-chapter', !slide);

      if (slide) {
        moveSlidesIntoReveal();
        if (!reveal) {
          body.classList.add('slides-loading');
          waitForCellsToSettle();
          reveal = new Reveal({
            embedded: false, hash: false, history: false,
            // Show "N / M" badge in the bottom-right corner. Counts
            // every slide including verticals (subslides).
            slideNumber: 'c/t',
            // Larger canvas than the reveal.js default (960x700)
            // so slides with a tall diagram plus bullets do not
            // overflow. reveal.js then auto-scales the canvas to
            // fit the viewport, so this is a content budget, not
            // a rendering size.
            //
            // minScale=0.1 lets the slide shrink well below the
            // canvas size on small viewports. maxScale=1.5 lets the
            // slide grow on wider monitors (the canvas at 1.5x is
            // about the width of a typical laptop screen) without
            // ballooning to the reveal.js default of 2.0, which
            // defeats Cmd+- until you hit 50%% browser zoom.
            width: 1280, height: 800, minScale: 0.1, maxScale: 1.5,
            // Without this, arrow keys while typing in an x-ocaml cell
            // also navigate slides. Shadow DOM hides the inner
            // contenteditable from document.activeElement (which sees
            // only the host <x-ocaml>), so reveal.js's built-in
            // "ignore inputs" check misses it.
            keyboardCondition: (_e) => {
              const ae = document.activeElement;
              if (ae && ae.tagName === 'X-OCAML') return false;
              // Walk into nested shadow roots in case future cells
              // are wrapped in other custom elements.
              let inner = ae && ae.shadowRoot && ae.shadowRoot.activeElement;
              while (inner && inner.shadowRoot && inner.shadowRoot.activeElement) {
                inner = inner.shadowRoot.activeElement;
              }
              if (inner && (inner.isContentEditable
                            || inner.tagName === 'TEXTAREA'
                            || inner.tagName === 'INPUT')) return false;
              return true;
            },
          });
          reveal.initialize().then(() => {
            // Restore last-viewed slide indices for this page from
            // sessionStorage so a refresh keeps your place.
            try {
              const key = 'nptel-slide:' + location.pathname;
              const saved = sessionStorage.getItem(key);
              if (saved) {
                const { h, v } = JSON.parse(saved);
                if (typeof h === 'number') reveal.slide(h, v ?? 0);
              }
            } catch (_) {}
            reveal.on('slidechanged', () => {
              try {
                const { h, v } = reveal.getIndices();
                sessionStorage.setItem(
                  'nptel-slide:' + location.pathname,
                  JSON.stringify({ h, v }));
              } catch (_) {}
              // Re-run KaTeX in case the slide contains math that
              // wasn't rendered on initial load (e.g. slides hidden
              // by reveal.js's display:none before first present).
              if (typeof renderMathInDocument === 'function') {
                try { renderMathInDocument(); } catch (_) {}
              }
            });
            // Reveal computes each section's vertical centering at
            // slidechange time. If a cell expands its output after
            // the slide is already on screen (the common case when
            // the user clicks Run on the current slide), the
            // section's top stays at the pre-expansion value and the
            // grown content drifts off the bottom of the canvas. A
            // ResizeObserver on each section triggers reveal.layout()
            // when content size changes, recentering the slide.
            let layoutPending = false;
            const requestLayout = () => {
              if (layoutPending) return;
              layoutPending = true;
              requestAnimationFrame(() => {
                layoutPending = false;
                reveal.layout();
              });
            };
            const ro = new ResizeObserver(requestLayout);
            for (const sec of document.querySelectorAll('.reveal .slides section[data-slide]')) {
              ro.observe(sec);
            }
          });
          // expose for testing / diagnostics
          window.Reveal = reveal;
        } else {
          reveal.sync();
          reveal.layout();
        }
      } else {
        restoreSlidesToChapter();
      }
    }

    modeBtn?.addEventListener('click', () => {
      if (isSlideMode()) {
        // Drop the trailing '#' cleanly; setting location.hash = '' keeps it.
        history.replaceState(null, '', location.pathname + location.search);
        syncMode();
      } else {
        location.hash = 'slides';
      }
    });
    window.addEventListener('hashchange', syncMode);
    syncMode();
  </script>|}
    asset_root

let render_sidebar ~(manifest : Manifest.t option) =
  match manifest with
  | None -> ""
  | Some m ->
      let buf = Buffer.create 2048 in
      Buffer.add_string buf "<aside class=\"sidebar chapter-only\">\n";
      Buffer.add_string buf
        "  <nav class=\"sidebar-nav\" aria-label=\"Course outline\">\n";
      Buffer.add_string buf
        "    <div class=\"sidebar-title\">Course outline</div>\n";
      (* Lecture numbering is per-module: each module's lectures
         start at L01. The entry's [lecture] field comes from the
         filename's [Lnn] segment. *)
      List.iter
        (fun (w : Manifest.week) ->
          let has_current =
            List.exists (fun (e : Manifest.entry) -> e.slug = m.current_slug)
              w.lectures
          in
          let opened = if has_current then " open" else "" in
          Buffer.add_string buf
            (Printf.sprintf "    <details class=\"sidebar-week\"%s>\n" opened);
          Buffer.add_string buf
            (Printf.sprintf
               "      <summary><span class=\"week-no\">M%02d</span> %s</summary>\n"
               w.week_no (Parse.html_escape w.week_title));
          Buffer.add_string buf "      <ul class=\"sidebar-lectures\">\n";
          List.iter
            (fun (e : Manifest.entry) ->
              let cls =
                if e.slug = m.current_slug then " class=\"current\"" else ""
              in
              Buffer.add_string buf
                (Printf.sprintf
                   "        <li%s><a href=\"%s.html\"><span \
                    class=\"lec-no\">L%02d</span> %s</a></li>\n"
                   cls e.slug e.lecture (Parse.html_escape e.title)))
            w.lectures;
          Buffer.add_string buf "      </ul>\n";
          Buffer.add_string buf "    </details>\n")
        m.weeks;
      Buffer.add_string buf "  </nav>\n";
      Buffer.add_string buf "</aside>\n";
      Buffer.contents buf

let render_prev_next ~(manifest : Manifest.t option) =
  match manifest with
  | None -> ""
  | Some m ->
      let prev, next = Manifest.neighbors m in
      (* Prev/next labels use per-module lecture numbers (M02 &middot; L03)
         to match the sidebar and the slide title. *)
      let label_of (e : Manifest.entry) =
        Printf.sprintf "M%02d &middot; L%02d" e.week e.lecture
      in
      let buf = Buffer.create 256 in
      Buffer.add_string buf
        "<nav class=\"prev-next chapter-only\" aria-label=\"Lecture navigation\">\n";
      (match prev with
       | Some (e : Manifest.entry) ->
           Buffer.add_string buf
             (Printf.sprintf
                "  <a class=\"prev\" href=\"%s.html\">&larr; <span \
                 class=\"label\">Previous</span> <span \
                 class=\"sub\">%s &middot; %s</span></a>\n"
                e.slug (label_of e) (Parse.html_escape e.title))
       | None -> Buffer.add_string buf "  <span class=\"prev disabled\"></span>\n");
      (match next with
       | Some (e : Manifest.entry) ->
           Buffer.add_string buf
             (Printf.sprintf
                "  <a class=\"next\" href=\"%s.html\"><span \
                 class=\"label\">Next</span> <span class=\"sub\">%s \
                 &middot; %s</span> &rarr;</a>\n"
                e.slug (label_of e) (Parse.html_escape e.title))
       | None -> Buffer.add_string buf "  <span class=\"next disabled\"></span>\n");
      Buffer.add_string buf "</nav>\n";
      Buffer.contents buf

let render_body ~html_body ~(fm : Frontmatter.t) ~manifest =
  let buf = Buffer.create (String.length html_body + 2048) in
  Buffer.add_string buf "<body class=\"mode-chapter\">\n";
  Buffer.add_string buf (header_bar ~fm);
  Buffer.add_string buf "\n";
  Buffer.add_string buf (render_sidebar ~manifest);
  (* In chapter mode the article holds everything inline. In slide mode
     a Reveal.js wrapper sibling becomes visible; the runtime script
     reparents the section[data-slide] elements into it on activation. *)
  Buffer.add_string buf "<article class=\"chapter\">\n";
  Buffer.add_string buf html_body;
  Buffer.add_string buf "\n</article>\n";
  Buffer.add_string buf (render_prev_next ~manifest);
  Buffer.add_string buf
    "<div class=\"reveal\" aria-hidden=\"true\"><div class=\"slides\"></div></div>\n";
  Buffer.add_string buf (footer_meta ~fm);
  Buffer.add_string buf "</body>\n";
  Buffer.contents buf

let render ~asset_root ~(fm : Frontmatter.t) ~html_body ?manifest () =
  let buf = Buffer.create (String.length html_body + 4096) in
  Buffer.add_string buf (head ~asset_root ~fm);
  Buffer.add_char buf '\n';
  Buffer.add_string buf (render_body ~html_body ~fm ~manifest);
  Buffer.add_string buf (runtime_script ~asset_root);
  Buffer.add_char buf '\n';
  Buffer.add_string buf "</html>\n";
  Buffer.contents buf
