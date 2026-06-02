# Phase 2: site integration (remaining work)

Phase 1 (image + prototype + perf gate) is done and approved; see
`README.md` for the design and measured numbers. This file is the
brief for what remains. Delete it when the work ships. Work top
to bottom; each step is independently verifiable. Read `AGENTS.md`
first.

STATUS 2026-06-02: steps 1, 2, 3, 4, 6, 7 are DONE (component at
assets/vm/vm-terminal.js; :::vm-terminal div in nptel-build with
unit+integration tests; playground.html + index links;
fplaunchpad/ocaml-browser-vm live with v1 and README; playwright
VM check wired as run-tests.sh stage 6/6). Step 5's M09 embeds are
ON HOLD: KC is editing M09 concurrently; do not touch M09 files
until he gives the all-clear. One design correction along the way:
the embed does NOT get a smaller RAM size; the snapshot's memory
geometry (512 MB / 8 MB VGA) must be matched exactly by the
component or state restore fails (see AGENTS.md gotcha).

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
     dedicated repo, `fplaunchpad/ocaml-browser-vm` (name chosen
     by KC), served via its own GitHub Pages, and point the
     playground page at that base URL. Use a versioned directory
     per image build (`v1/`, `v2/`, ...) holding the chunk store,
     state, and fs.json together: they must always come from the
     same rootfs build; the course-side component pins one
     directory, so the two repos never need synchronized deploys
     and rollback is trivial. Every file is well under GitHub's
     100 MB limit and v86 fetches chunks whole (no Range requests
     needed). CORS: GitHub Pages sends
     `access-control-allow-origin: *`, so cross-repo fetches are
     fine. Suggested repo description: "Bootable Linux VM image
     (OCaml 5.4 + dune + bisect_ppx) served as lazy chunks to the
     in-browser v86 emulator for the NPTEL OCaml course."
   - KC has approved creating this one repo; any OTHER new repo
     still needs his sign-off.
4. **Sample projects: DONE (KC chose).** The image ships
   `hello/`, `morse/`, and `bowling/`; domains verified fresh
   against the lectures (RLE, dates, triangles, and matrix were
   ruled out as already used; the earlier `roman/` placeholder
   was dropped by KC). Both libraries carry
   `(instrumentation (backend bisect_ppx))`; the demo flow is
   `dune build --instrument-with bisect_ppx`, then
   `bisect-ppx-report summary`. Further opam libraries or new
   projects only with KC's sign-off.
5. **Index + lecture embeds (KC decided: module 9).** Add the
   playground to `index.html` (emit_index in build-site.sh). The
   `:::vm-terminal` embeds go in the M09 (testing) lectures:
   pick the natural spots (e.g. where dune runtest and bisect_ppx
   coverage are taught), at most one embed per lecture, and show
   KC the diff before it lands. No embeds in other modules
   without asking. Per course convention, link text must be
   descriptive ("the in-browser dune playground"), never "the
   M09 page".
6. **Playwright end-to-end check.** Extend the playwright suite
   invoked by `tools/run-tests.sh`: load the playground page,
   wait for the serial prompt (match the suffix `:~# `, never an
   exact hostname), send
   `cd hello && dune build && ./_build/default/hello.exe`, assert
   the expected output line appears. Generous timeout (~90 s);
   CI machines are slower than KC's laptop. Also verify
   `bash tools/run-tests.sh` stays green end-to-end: the
   playground must not disturb lecture builds or mdx tests.
7. **VM-data repo documentation.** `fplaunchpad/ocaml-browser-vm`
   gets a short README: rebuild commands (point at tools/vm-image
   in the course repo), the Docker requirement, and the pinned
   versions; record the resulting OCaml/dune versions and the
   versioned directory name on every rebuild.
