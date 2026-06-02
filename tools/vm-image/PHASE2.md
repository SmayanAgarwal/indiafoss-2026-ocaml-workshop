# Phase 2: site integration (remaining work)

Phase 1 (image + prototype + perf gate) is done and approved; see
`README.md` for the design and measured numbers. This file is the
brief for what remains. Delete it when the work ships. Work top
to bottom; each step is independently verifiable. Read `AGENTS.md`
first.

1. **Embeddable terminal component (KC decision: build "both",
   component + standalone page).** A single self-contained JS
   component (`assets/vm/vm-terminal.js` + css) that renders a
   static click-to-boot placeholder and fetches NOTHING (engine,
   state, chunks) until the student clicks "Start the VM".
   Constraints: one VM instance per page (each holds the guest
   RAM buffer; use 256 MB for embeds), xterm.js wired to serial0
   (`emulator.add_listener("serial0-output-byte", ...)` +
   `emulator.serial0_send(...)`; the image runs an autologin
   getty on ttyS0). Vendor xterm.js (MIT) under `assets/vm/`; no
   CDN, no npm build step at site-build time. Keep a loading
   progress line and a "downloaded so far" counter (NPTEL
   students are often bandwidth-constrained). Support a
   start-directory option (e.g. boot into `/root/roman`).
   Student work is per-visit (reload = fresh snapshot); that is
   acceptable for now. Later niceties: save/restore via
   `emulator.save_state()` to IndexedDB; "download your work" and
   a coverage-report viewer via `emulator.read_file()` (proven in
   Phase 1).
2. **Chapter embedding + standalone page.**
   - New fenced div for lectures, e.g. `:::vm-terminal` (with an
     optional start-dir argument), emitted by `nptel-build`
     (`tools/nptel-build/lib/emit.ml`): chapter page only, NOT
     the reveal slide deck. Asset injection follows the existing
     per-module bundle pattern in emit.ml. At most one per
     lecture; the emitter should error on a second instance.
   - Standalone playground page: an `emit_playground()` shell
     function in `tools/build-site.sh`, modelled on the three
     existing standalone heredoc pages (index/privacy/dashboard;
     they bypass `nptel-build` entirely). Content: short framing
     paragraph, the same component, the sample-project
     cheat-sheet (`cd hello && dune build && dune exec
     ./hello.exe`, etc.). Respect the `ASSET_ROOT` variable like
     lecture pages do so the page works both locally and under
     the `/ocaml_nptel` prefix on Pages.
3. **Asset hosting split.**
   - Commit to the main repo, under `assets/vm/`: libv86.js,
     v86.wasm, seabios.bin, vgabios.bin, xterm.js (+ css), the
     page JS. ~3 MB total. Follow the existing cache-buster
     query-param convention (see how emit.ml/build-site.sh
     version x-ocaml assets).
   - Do NOT commit: `ocaml-state.bin.zst` (~9 MB),
     `ocaml-fs.json` (~190 KB), `ocaml-rootfs-flat/` (~153 MB,
     thousands of small files). Host these in a separate
     dedicated repo under the `fplaunchpad` org (e.g.
     `fplaunchpad/ocaml-vm-image`) served via its own GitHub
     Pages, and point the playground page at that base URL.
     Every file is well under GitHub's 100 MB limit and v86
     fetches chunks whole (no Range requests needed). CORS:
     GitHub Pages sends `access-control-allow-origin: *`, so
     cross-repo fetches are fine.
   - Check with KC before creating any new repo.
4. **Sample projects (needs KC sign-off).** `hello/` is fine.
   `roman/` was a prototype placeholder: before going
   student-facing, check it against the course's fresh-code and
   domain-overlap conventions (no project that re-derives code a
   lecture already walks through; no domain another lecture's
   tutorial already uses). Propose 2-3 candidate projects to KC
   and let him pick. bisect_ppx is baked into the image (the
   roman sample's library stanza carries
   `(instrumentation (backend bisect_ppx))`; build with
   `dune build --instrument-with bisect_ppx`, then
   `bisect-ppx-report summary`). Further opam libraries only if
   KC asks.
5. **Index + lecture links.** Add the playground to `index.html`
   (emit_index in build-site.sh). Linking from specific lectures
   is KC's call; ask, do not guess. Per course convention, link
   text must be descriptive ("the in-browser dune playground"),
   never "the M09 page".
6. **Playwright end-to-end check.** Extend the playwright suite
   invoked by `tools/run-tests.sh`: load the playground page,
   wait for the serial prompt (match the suffix `:~# `, never an
   exact hostname), send
   `cd hello && dune build && ./_build/default/hello.exe`, assert
   the expected output line appears. Generous timeout (~90 s);
   CI machines are slower than KC's laptop. Also verify
   `bash tools/run-tests.sh` stays green end-to-end: the
   playground must not disturb lecture builds or mdx tests.
7. **VM-data repo documentation.** Whatever repo hosts the chunk
   store gets a short README: rebuild commands (point at
   tools/vm-image in the course repo), the Docker requirement,
   and the pinned versions; record the resulting OCaml/dune
   versions on every rebuild.
