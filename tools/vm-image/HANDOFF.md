# Dune-in-the-browser playground: handoff plan

Status: Phase 1 (prototype + perf gate) is DONE and approved.
This file is the brief for the remaining work (Phase 2: site
integration). It is self-contained; read it top to bottom before
touching anything.

Sources live HERE, committed, in `tools/vm-image/` (README.md has
the quickstart). Heavy inputs and build outputs live in the
untracked scratch dir `_vm-prototype/` at the repo root, populated
by `setup-scratch.sh`: the leading underscore keeps it out of the
repo's dune workspace and the site build. Never commit the scratch
dir; Phase 2 below says where its outputs eventually get hosted.

## What this is

A student-facing playground page for the NPTEL course where a
real shell with `dune build` / `dune runtest` / `dune exec` runs
entirely in the browser. No backend, static hosting only
(GitHub Pages), OSS components only, packages baked into the
image (no live `opam install`, no network inside the VM).

Technology: v86 (<https://github.com/copy/v86>, BSD-2-Clause),
an x86-to-wasm JIT emulator, running 32-bit Alpine Linux 3.23
with OCaml 5.4.0 (bytecode-only; there is no 32-bit native
backend in OCaml 5, and KC confirmed bytecode is fine) and dune
3.20.2, both straight from Alpine's x86 apk repos. The VM resumes
from a zstd-compressed post-boot snapshot (no kernel boot at page
load) and lazily fetches rootfs chunks over 9p, so students only
download the files they actually touch.

Rejected alternatives, for the record: WebVM/CheerpX (academic
use needs a commercial license; engine not self-hostable),
container2wasm (interpreted CPU, way too slow for dune),
WebContainers (Node-only), toolchain-to-WASI (dune needs
fork/exec of subprocesses; browser WASI shims have none).

## Phase 1 results (final image, measured 2026-06-02, localhost)

Image: Alpine 3.23 / OCaml 5.4.0 (bytecode) / dune 3.20.2 (native
apk binary) / bisect_ppx (PR-448 pin) / opam switch trimmed.

- Page load to interactive shell prompt: ~1 s after ~12 MB
  initial download (9.0 MB zstd state + 2.4 MB engine + fs.json).
- Plain dune workflow: hello cold build 6.5 s; multi-module
  lib+bin+test cold build 12-17 s; runtest 0.6 s; no-op 0.3 s;
  incremental 3.3 s.
- Coverage workflow: first `dune build --instrument-with
  bisect_ppx` is ~90 s cold (dominated by the one-time
  per-project ppx driver link); after that, instrumented
  runtest 2.4 s, `bisect-ppx-report summary` instant. Verified
  end-to-end headlessly (run-workflow.mjs, 117 s total).
- Downloads (cold cache, exact from server logs): boot-only
  ~12 MB; running EVERYTHING incl. coverage fetches ~41 MB of
  chunks, ~53 MB total. The chunk store on disk is 153 MB
  (after trimming; was 264 MB), of which untouched chunks are
  never downloaded.
- Biggest single chunks a session fetches: gcc cc1 12.7 MB,
  ocamlcommon.cma 6.9 MB, dune 4 MB, ppxlib cmas ~4 MB.

Gate targets (interactive < 10 s, initial < 50 MB, plain builds
~15 s) met. KC chose OCaml 5.4.0 (bytecode-only fine), bisect_ppx
baked in, hybrid apk+opam policy, and the 90 s one-time
instrumented-build cost was accepted as inherent.

## Directory layout

- `image/Dockerfile`: i386 Alpine + ocaml5 + dune + musl-dev +
  nano/less, serial autologin, 9p initramfs. Read its comments;
  two hard-won gotchas live there (see Gotchas below).
  Libraries beyond the stdlib come in two tiers, both baked at
  image-build time (no network inside the VM): apk for the few
  OCaml libs Alpine packages, and an opam layer (`opam init
  --compiler=ocaml-system` against the apk OCaml, then
  `opam install ...`) for everything else. bisect_ppx is
  installed this way at KC's request (coverage, M09-relevant).
  bisect_ppx has no OCaml 5.4-compatible release as of June
  2026; the image pins the ppxlib-0.36 port from upstream PR
  aantron/bisect_ppx#448 (patricoferris fork, KC-approved).
  When #448 merges and ships, replace the pin with a plain
  `opam install bisect_ppx`. Policy decision by KC: keep the
  hybrid (apk compiler + native apk dune for speed inside the
  emulated VM, opam only for libraries); do not move the
  compiler or dune into opam, since a bytecode-only switch
  would make dune itself bytecode and slow every student build.
  The opam layer sits above the COPY of sample projects so
  project edits don't invalidate it; it is expensive to rebuild
  (qemu-emulated ppxlib build).
- `image/projects/`: sample dune projects baked into `/root/`
  (`hello/`, `roman/`). PROTOTYPE PLACEHOLDERS; see Phase 2 step 4.
- `image/build.sh`: docker build (linux/386) -> rootfs tar ->
  `images/ocaml-fs.json` (metadata) + `images/ocaml-rootfs-flat/`
  (zstd chunk store, content-addressed). Needs Docker running and
  `python3 -c 'import zstandard'` to succeed.
- `make-state.mjs`: boots the image headlessly in node (v86 runs
  in node too), waits for the shell prompt, drops page caches,
  saves `images/ocaml-state.bin`. Compress it afterwards:
  `zstd -19 -f images/ocaml-state.bin -o images/ocaml-state.bin.zst`
- `run-workflow.mjs`: headless end-to-end verification: restores
  the snapshot, runs the full plain+coverage workflow over
  serial, asserts the Coverage line. Run it after every image
  rebuild; it is also the template for the playwright CI check.
- `prototype.html`: the demo page (VGA text console + serial
  timing instrumentation). The eventual playground page should be
  a nicer evolution of this (xterm.js on serial; see Phase 2).
- `setup-scratch.sh`: populates the scratch dir with the pinned
  third-party inputs: a clone of copy/v86 at commit `e37189a`
  (only `bios/*.bin` and `tools/*.py` are used) plus the prebuilt
  engine from npm `v86@0.5.359` (libv86.js/.mjs, v86.wasm; we
  never compile v86). Build outputs land in
  `_vm-prototype/images/`. All regenerable; never commit.

Full rebuild from scratch:

```sh
bash tools/vm-image/setup-scratch.sh   # once
bash tools/vm-image/image/build.sh
node tools/vm-image/make-state.mjs
zstd -19 -f _vm-prototype/images/ocaml-state.bin \
     -o _vm-prototype/images/ocaml-state.bin.zst
node tools/vm-image/run-workflow.mjs   # must print "workflow complete"
(cd _vm-prototype && python3 -m http.server 8766)  # /prototype.html
```

Any change to `image/` requires re-running ALL THREE steps: the
snapshot embeds 9p metadata consistent with `ocaml-fs.json`, so a
stale state file against a fresh fs.json is undefined behaviour.

## Phase 2: site integration (the remaining work)

Work top to bottom; each step is independently verifiable.

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
   acceptable for now. A later nicety: save/restore via
   `emulator.save_state()` to IndexedDB, and "download your
   work" via `emulator.read_file()`.
2. **Chapter embedding + standalone page.**
   - New fenced div for lectures, e.g. `:::vm-terminal` (with an
     optional start-dir argument), emitted by `nptel-build`
     (`tools/nptel-build/lib/emit.ml`): chapter page only, NOT
     the reveal slide deck. Asset injection follows the existing
     per-module bundle pattern in emit.ml. At most one per
     lecture; the emitter should error on a second instance.
   - Standalone playground page: an `emit_playground()` shell
     function in `tools/build-site.sh`, modelled on the three
     existing standalone heredoc pages (index/privacy/dashboard,
     roughly lines 72-933; they bypass `nptel-build` entirely).
     Content: short framing paragraph, the same component, the
     sample-project cheat-sheet (`cd hello && dune build &&
     dune exec ./hello.exe`, etc.). Respect the `ASSET_ROOT`
     variable like lecture pages do so the page works both
     locally and under the `/ocaml_nptel` prefix on Pages.
3. **Asset hosting split.**
   - Commit to the main repo, under `assets/vm/`: libv86.js,
     v86.wasm, seabios.bin, vgabios.bin, xterm.js (+ css), the
     page JS. ~3 MB total. Follow the existing cache-buster
     query-param convention (see how emit.ml/build-site.sh
     version x-ocaml assets).
   - Do NOT commit: `ocaml-state.bin.zst` (~9 MB),
     `ocaml-fs.json` (~190 KB), `ocaml-rootfs-flat/` (~130 MB,
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
   KC asks; each one grows the chunk store.
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
7. **Image rebuild documentation.** The rootfs build (this
   directory) stays out of the main repo for now. Write a short
   README in whatever repo hosts the VM data covering: the
   rebuild commands above, the Docker daemon requirement, and the
   gotchas below. Pin the base image tag (currently
   `i386/alpine:3.23`) and record the resulting OCaml/dune
   versions in the README on every rebuild.

## Gotchas (every one of these cost real debugging time)

- **Docker bind-mounts `/etc/hostname` during build**: writes to
  it (including via `setup-hostname`) do not survive into the
  exported rootfs; it ends up holding the build container's ID.
  The hostname is set from `/etc/profile` instead. Relatedly, the
  serial getty races the openrc hostname service, so never match
  an exact `hostname:~# ` prompt string; match the suffix
  `":~# "`.
- **dune needs musl-dev even for bytecode**: linking a bytecode
  executable's custom runtime compiles a C stub. Without the
  headers you get `fatal error: stdlib.h: No such file or
  directory` from deep inside dune. gcc itself arrives as an
  ocaml5 dependency.
- **Building the sample projects on the host**: the course repo
  root is itself a dune workspace, so run `dune build --root .`
  inside each sample project, and delete `_build/` before
  rebuilding the image.
- **fs.json and the state snapshot must come from the same
  rootfs build** (see rebuild note above).
- **Serving**: plain `python3 -m http.server` is enough (no Range
  requests involved anywhere). The repo's usual preview server on
  :8765 is rooted at `_site/`, hence the separate :8766 server
  here.
- **node make-state.mjs appears to hang**: it is emulating a full
  kernel boot; ~20 s of silence is normal. Output goes through a
  serial listener; if you pipe it through `tail`, you see nothing
  until exit.
- **dune versions must match between apk and the opam switch**:
  an older dune cannot read `dune-package` metadata installed by
  a newer one (`Version 3.23 of the dune language is not
  supported`). Hence the `opam pin add dune $(dune --version)` in
  the Dockerfile; keep that in sync if the Alpine dune bumps.
- **Trimming works anywhere in the Dockerfile** because the
  rootfs comes from `docker export` (flattened); a later-layer
  `rm` genuinely shrinks the chunk store, unlike normal layered
  images. Biggest wins already taken: opam repo index (178 MB),
  `.cmt`/`.cmti` (49 MB). The static `/etc/profile.d/opam.sh` is
  captured BEFORE the repo is deleted; `eval $(opam env)` would
  not survive the trim.
- **A restored snapshot emits no serial output on its own**: the
  prompt was printed before the state was saved. Anything waiting
  on serial must first send `"\n"` to elicit a fresh prompt
  (prototype.html and run-workflow.mjs both do).
- **node libv86 reads chunks via fs, not HTTP**: a baseurl URL
  silently hangs the 9p filesystem in node; use a local directory
  path there. HTTP baseurl is for the browser.
- **Measuring downloads in the page**: count only
  `transferSize > 0` (cache hits report 0; falling back to
  `encodedBodySize` double-counts re-reads) and call
  `performance.setResourceTimingBufferSize(50000)` early; the
  default 250-entry buffer silently drops chunk entries. The
  server access log is the ground truth when in doubt.

## Course conventions that apply here

- No em-dashes in prose (no `—` and no `--` digram), in any file
  including this one, commit messages, and the playground page
  copy.
- Slides/pages wrap prose at ~70 columns.
- Committed files must not reference uncommitted/local-only
  content (`_references/`, `/Users/...`, this directory).
- Do not push to `main` after non-trivial restructuring without
  showing KC the diff first.
- For cross-cutting decisions (new repo, which lectures link
  here, sample-project choice): ask KC, do not improvise.
