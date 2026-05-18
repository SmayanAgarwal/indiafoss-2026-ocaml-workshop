(* Emit a single self-contained HTML page that hosts both the chapter
   view and a reveal.js slide view of the same content. The mode is
   selected client-side by the toggle button or the [#slides] URL hash.

   Asset paths are computed relative to the lecture HTML file's location
   inside [_site/], using a single configurable depth: the number of
   path segments between the lecture file and the repo root. For
   [_site/week01-intro/L02-what-is-fp.html] the depth is 2; for
   [_site/test/smoke.html] the depth is 2 as well. We just pass
   [relative_root] as a string like ["../.."]. *)

let head ~asset_root ~(fm : Frontmatter.t) =
  (* [asset_root] is the prefix used in front of each asset path. For
     production we use root-relative paths like ["/assets/..."], so
     callers pass [""] and the leading slash comes from each href.
     For previewing inside a subdirectory (e.g. when assets live under
     [/_site/]), the caller can pass that prefix instead. *)
  Printf.sprintf
    {|<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
  <title>%s</title>
  <link rel="stylesheet" href="%s/assets/reveal/dist/reveal.css">
  <link rel="stylesheet" href="%s/assets/reveal/dist/theme/white.css" id="reveal-theme">
  <link rel="stylesheet" href="%s/assets/css/chapter.css">
  <link rel="stylesheet" href="%s/assets/css/slides.css">
  <script async
    src="%s/assets/x-ocaml/x-ocaml.js"
    src-worker="%s/assets/x-ocaml/x-ocaml.worker.js"></script>
</head>|}
    (Parse.html_escape (if fm.title = "" then "(untitled lecture)" else fm.title))
    asset_root asset_root asset_root asset_root asset_root asset_root

let header_bar ~(fm : Frontmatter.t) =
  let lecture_id =
    match fm.lecture_no, fm.week with
    | Some l, Some w -> Printf.sprintf "Module %d &middot; Lecture %d" w l
    | _ -> ""
  in
  let title = if fm.title = "" then "(untitled)" else Parse.html_escape fm.title in
  Printf.sprintf
    {|  <header class="page-header">
    <button class="sidebar-collapse chapter-only" type="button" title="Show or hide the course outline" aria-label="Toggle course outline">&#9776;</button>
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
      return cell.previousElementSibling?.classList?.contains('reset-cell')
        ? cell.previousElementSibling
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
    const persistTimers = new WeakMap();
    function schedulePersist(cell) {
      clearTimeout(persistTimers.get(cell));
      persistTimers.set(cell, setTimeout(() => persistCell(cell), 700));
    }
    function watchCellForEdits(cell) {
      // Use [input] events on the editor's contenteditable surface
      // rather than a MutationObserver: [input] fires only on user
      // typing, not on programmatic DOM changes from output widgets.
      // This avoids two failure modes: saving widget text as "source",
      // and looping when x-ocaml re-renders the editor after persist.
      const ed = cell.shadowRoot?.querySelector('.cm-content');
      if (!ed) return;
      ed.addEventListener('input', () => schedulePersist(cell));
    }
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

    // Inject a per-cell reset button as a light-DOM sibling. We cannot
    // touch the Run button (it lives in the shadow root) so the reset
    // sits next to the cell.
    function injectResetButtons() {
      for (const cell of allCells()) {
        if (cell.previousElementSibling?.classList?.contains('reset-cell')) continue;
        const btn = document.createElement('button');
        btn.type = 'button';
        btn.className = 'reset-cell';
        btn.title = 'Reset this cell to its source';
        btn.textContent = '↺';  // anticlockwise open circle arrow
        btn.addEventListener('click', () => resetCell(cell));
        cell.parentNode.insertBefore(btn, cell);
      }
    }
    injectResetButtons();

    // After x-ocaml upgrades each cell (Run button appears in shadow),
    // wire persistence and restore any saved edits.
    async function whenCellsReady() {
      while (true) {
        const ready = allCells().every(c => c.shadowRoot?.querySelector('.cm-content'));
        if (ready) break;
        await new Promise(r => setTimeout(r, 100));
      }
      restorePersistedCells();
      for (const c of allCells()) watchCellForEdits(c);
    }
    whenCellsReady();

    document.querySelector('.run-all')?.addEventListener('click', runAll);
    document.querySelector('.run-up-to-here')?.addEventListener('click', runUpToHere);
    document.querySelector('.clear-all')?.addEventListener('click', clearAll);
    document.querySelector('.reset-all')?.addEventListener('click', resetAll);

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
    // The button inside the sidebar (rendered by [render_sidebar]) does
    // the same thing.
    document.querySelector('.sidebar-toggle')?.addEventListener('click', toggleSidebar);

    function syncMode() {
      const slide = isSlideMode();
      body.classList.toggle('mode-slides', slide);
      body.classList.toggle('mode-chapter', !slide);

      if (slide) {
        moveSlidesIntoReveal();
        if (!reveal) {
          reveal = new Reveal({ embedded: false, hash: false, history: false });
          reveal.initialize();
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
        "  <button class=\"sidebar-toggle\" type=\"button\" \
         aria-label=\"Toggle navigation\">&#9776;</button>\n";
      Buffer.add_string buf
        "  <nav class=\"sidebar-nav\" aria-label=\"Course outline\">\n";
      Buffer.add_string buf
        "    <div class=\"sidebar-title\">Course outline</div>\n";
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
      let buf = Buffer.create 256 in
      Buffer.add_string buf
        "<nav class=\"prev-next chapter-only\" aria-label=\"Lecture navigation\">\n";
      (match prev with
       | Some (e : Manifest.entry) ->
           Buffer.add_string buf
             (Printf.sprintf
                "  <a class=\"prev\" href=\"%s.html\">&larr; <span \
                 class=\"label\">Previous</span> <span \
                 class=\"sub\">M%02d L%02d &middot; %s</span></a>\n"
                e.slug e.week e.lecture (Parse.html_escape e.title))
       | None -> Buffer.add_string buf "  <span class=\"prev disabled\"></span>\n");
      (match next with
       | Some (e : Manifest.entry) ->
           Buffer.add_string buf
             (Printf.sprintf
                "  <a class=\"next\" href=\"%s.html\"><span \
                 class=\"label\">Next</span> <span class=\"sub\">W%02d \
                 L%02d &middot; %s</span> &rarr;</a>\n"
                e.slug e.week e.lecture (Parse.html_escape e.title))
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
