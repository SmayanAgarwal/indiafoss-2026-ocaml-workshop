# Agent guidance for tools/vm-image

Standing instructions for working on the in-browser dune VM.
Background and design rationale: `README.md`.

## Standing policies (KC decisions)

- `:::vm-terminal` embeds live in module 9 (L03, L04), module 10
  (the C memory-safety demos in `/root/m10`), and module 12 (the
  mirage hello project in `/root/m12/hello`: L03 edit-rebuild-run,
  L04 configure-retarget; KC signed off 2026-06-12), at most one
  per lecture (the build enforces this); embedding in any other
  module needs KC's sign-off.
- Deployed data is a single `current/` directory in the
  `fplaunchpad/ocaml-browser-vm` repo, overwritten per build; git
  history is the rollback path (the old immutable-`vN/` scheme is
  retired). `DEFAULT_BASE` in `assets/vm/vm-terminal.js` points at
  `current/` and does not change per build.
- The terminal exists as both the chapter embed and the
  standalone playground page; both use the same component at
  `assets/vm/vm-terminal.js`.
- Student work is per-visit (reload = fresh snapshot). Accepted
  future niceties, unscheduled: save/restore to IndexedDB via
  `emulator.save_state()`, and a "download your work" button via
  `emulator.read_file()` (the coverage-report button already
  demonstrates the lift-out mechanism).

## Rebuild discipline

- Any change under `image/` requires re-running ALL of:
  `image/build.sh`, `make-state.mjs`, and the zstd compression
  step (see README quickstart). The snapshot embeds 9p metadata
  consistent with `ocaml-fs.json`; a stale state file against a
  fresh fs.json is undefined behaviour.
- After every rebuild, `node tools/vm-image/run-workflow.mjs`
  must print `workflow complete: Coverage: ...`. Treat a TIMEOUT
  as a broken image, not a flaky test (but see the serial-poke
  gotcha below before concluding that).
- The opam layer is expensive (~25 min qemu-emulated ppxlib
  build) and is cached by layer; keep it ABOVE the
  `COPY projects/` line so sample-project edits don't invalidate
  it. Transient DNS failures inside docker build do happen;
  retry before debugging.

## Maintenance pins

- The Dockerfile pins the opam switch's dune to the apk dune's
  version (`opam pin add dune $(dune --version)`): keep these in
  lockstep when the Alpine base bumps.
- bisect_ppx is pinned to upstream PR aantron/bisect_ppx#448
  (patricoferris fork, KC-approved): replace with plain
  `opam install bisect_ppx` once a release supports OCaml 5.4 /
  ppxlib >= 0.36.
- setup-scratch.sh pins the v86 repo commit and npm engine
  version; bump deliberately, then full-rebuild and re-verify.

## Gotchas (every one cost real debugging time)

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
- **dune versions must match between apk and the opam switch**:
  an older dune cannot read `dune-package` metadata installed by
  a newer one (`Version 3.23 of the dune language is not
  supported`).
- **Trimming works anywhere in the Dockerfile** because the
  rootfs comes from `docker export` (flattened); a later-layer
  `rm` genuinely shrinks the chunk store, unlike normal layered
  images. Biggest wins already taken: opam repo index (178 MB),
  `.cmt`/`.cmti` (49 MB). The static `/etc/profile.d/opam.sh` is
  captured BEFORE the repo is deleted; `eval $(opam env)` would
  not survive the trim.
- **State restore requires identical memory geometry**: the
  `memory_size` and `vga_memory_size` passed to V86 must exactly
  match the values make-state.mjs used when saving the snapshot
  (currently 512 MB / 8 MB); a mismatch fails with
  "RangeError: offset is out of bounds" inside set_state. The
  course-side component (assets/vm/vm-terminal.js) hardcodes the
  same values; change them in lockstep.
- **A restored snapshot emits no serial output on its own**: the
  prompt was printed before the state was saved. Anything waiting
  on serial must first send `"\n"` to elicit a fresh prompt
  (prototype.html and run-workflow.mjs both do).
- **node libv86 reads chunks via fs, not HTTP**: a baseurl URL
  silently hangs the 9p filesystem in node; use a local directory
  path there. HTTP baseurl is for the browser.
- **emulator.read_file cannot see freshly written guest files**:
  the guest mounts 9p with cache=loose, so new files sit in the
  guest page cache until writeback (default ~30 s). Run `sync` in
  the guest before host-side reads (the coverage viewer's
  documented command does), and the image sets fast writeback
  sysctls (99-writeback.conf, from v3 data onward).
- **node make-state.mjs appears to hang**: it is emulating a full
  kernel boot; ~20 s of silence is normal. Output goes through a
  serial listener; piped through `tail`, you see nothing until
  exit.
- **Building the sample projects on the host**: the course repo
  root is itself a dune workspace, so run `dune build --root .`
  inside each sample project, and delete `_build/` before
  rebuilding the image. (`tools/vm-image/dune` declares
  `(data_only_dirs image)` to keep the baked projects out of the
  root workspace; keep it.)
- **Serving**: plain `python3 -m http.server` is enough (no Range
  requests involved anywhere). The repo's usual preview server on
  :8765 is rooted at `_site/`, hence a separate :8766 server for
  the scratch dir.
- **Measuring downloads in the page**: count only
  `transferSize > 0` (cache hits report 0; falling back to
  `encodedBodySize` double-counts re-reads) and call
  `performance.setResourceTimingBufferSize(50000)` early; the
  default 250-entry buffer silently drops chunk entries. The
  server access log is the ground truth when in doubt.
- **Browser-based checks die if the driven Chrome window is
  closed**: the VM lives in the page. Prefer the headless
  `run-workflow.mjs` for verification.

## Ask KC first (do not improvise)

- Creating any new repo (e.g. for hosting the chunk store).
- Choosing or changing the baked sample projects (fresh-code and
  domain-overlap conventions apply; see the course CLAUDE.md).
- Which lectures embed or link the terminal.
- Adding opam libraries to the image (each grows the chunk
  store).
- Building from third-party forks or unreleased sources.

## Course conventions that apply here

- No em-dashes in prose (no `—` and no `--` digram), including
  commit messages and page copy.
- Prose wraps at ~70 columns.
- Committed files must not reference uncommitted/local-only
  content (`_references/`, `/Users/...`, the scratch dir's
  contents).
- Do not push to `main` after non-trivial restructuring without
  showing KC the diff first.
