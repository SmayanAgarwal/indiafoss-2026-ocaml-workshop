# vm-image: dune-in-the-browser VM build tooling

Builds the Linux VM image that powers the in-browser dune
terminal: 32-bit Alpine with OCaml 5.4.0 (bytecode), dune, and
bisect_ppx, run by the v86 emulator (x86-to-wasm JIT) entirely
client-side, with the rootfs lazily fetched as zstd chunks over
9p and an instant-resume boot snapshot.

Full design, decision log, Phase 2 integration plan, and gotchas:
see `HANDOFF.md` in this directory.

## Layout

- `image/Dockerfile`: the VM filesystem (read its comments).
- `image/projects/`: sample dune projects baked into `/root/`.
- `image/build.sh`: Docker image -> rootfs tar -> fs.json +
  chunk store.
- `make-state.mjs`: headless boot, saves the resume snapshot.
- `run-workflow.mjs`: headless end-to-end smoke test.
- `prototype.html`: minimal demo page (Phase 1 prototype).
- `setup-scratch.sh`: fetches the pinned third-party inputs.

Heavy inputs and all build outputs live in an untracked scratch
dir, `_vm-prototype/` at the repo root (override: `VM_SCRATCH`).
Never commit the scratch dir.

## Quickstart (needs Docker, node, python3 + zstandard, zstd)

```sh
bash tools/vm-image/setup-scratch.sh
bash tools/vm-image/image/build.sh
node tools/vm-image/make-state.mjs
zstd -19 -f _vm-prototype/images/ocaml-state.bin \
     -o _vm-prototype/images/ocaml-state.bin.zst
node tools/vm-image/run-workflow.mjs        # must end "workflow complete"
(cd _vm-prototype && python3 -m http.server 8766)
# open http://localhost:8766/prototype.html
```

Any change under `image/` requires re-running build.sh,
make-state.mjs, and the zstd step together: the snapshot and
fs.json must come from the same rootfs build.

## Pinned versions

- Base: `i386/alpine:3.23` (OCaml 5.4.0, dune 3.20.2 from apk).
- v86 repo: commit `e37189a` (tools + BIOS); engine: npm
  `v86@0.5.359` (prebuilt libv86 + v86.wasm; never compiled here).
- bisect_ppx: pinned in the Dockerfile to upstream PR #448's head
  (OCaml 5.4 / ppxlib >= 0.36 port); swap to the opam release
  when it ships.
