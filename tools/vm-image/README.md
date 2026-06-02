# vm-image: dune-in-the-browser VM

Builds the Linux VM image behind the course's in-browser dune
terminal: a real shell where students run `dune build` /
`dune runtest` / `dune exec` (and bisect_ppx coverage) entirely
client-side. No backend, static hosting only (GitHub Pages), OSS
components only, packages baked into the image (no live
`opam install`, no network inside the VM).

Agents working in this directory: read `AGENTS.md`. The remaining
site-integration work is specced in `PHASE2.md`.

## Design

v86 (<https://github.com/copy/v86>, BSD-2-Clause), an x86-to-wasm
JIT emulator, runs 32-bit Alpine Linux 3.23 with OCaml 5.4.0
(bytecode-only; OCaml 5 has no 32-bit native backend) and dune
3.20.2, both from Alpine's x86 apk repos. The VM resumes from a
zstd-compressed post-boot snapshot (no kernel boot at page load)
and lazily fetches rootfs chunks over 9p, so students download
only the files their commands actually touch.

Libraries come in two tiers, both baked at image-build time: apk
for the few OCaml libs Alpine packages, and an opam layer (switch
on `ocaml-system`, i.e. the apk compiler) for everything else;
bisect_ppx is installed that way. Policy: the compiler and dune
stay apk (the native dune binary is what keeps builds fast under
emulation); opam is for libraries only.

Rejected alternatives, for the record: WebVM/CheerpX (academic
use needs a commercial license; engine not self-hostable),
container2wasm (interpreted CPU, too slow for dune), WebContainers
(Node-only), toolchain-to-WASI (dune needs fork/exec of
subprocesses; browser WASI shims have none).

## Measured (2026-06-02, localhost serving)

- Page load to interactive shell: ~1 s after ~12 MB initial
  download (9.0 MB zstd state + 2.4 MB engine + fs.json).
- Plain dune: hello cold build 6.5 s; multi-module lib+bin+test
  cold 12-17 s; runtest 0.6 s; no-op 0.3 s; incremental 3.3 s.
- Coverage: instrumenting a project from scratch is ~90 s, of
  which 72 s is ONE ocamlc invocation linking the per-project
  ppx driver against ppxlib (measured with dune --trace-file
  inside the VM; running the instrumenter itself costs 0.6 s).
  bowling's instrumented _build is pre-baked into the image
  (v3), so the student's first instrumented run there is ~20 s
  (digest re-checks over 9p) and later runs ~2 s.
  `bisect-ppx-report summary` is instant; the HTML report is
  lifted out of the VM via `emulator.read_file()` (the
  terminal's "coverage report" button).
- Downloads (cold cache): boot-only ~12 MB; running everything
  incl. coverage ~53 MB total. Chunk store on disk: 153 MB, of
  which untouched chunks are never downloaded. Biggest session
  chunks: gcc cc1 12.7 MB, ocamlcommon.cma 6.9 MB, dune 4 MB.

## Layout

- `image/Dockerfile`: the VM filesystem (read its comments).
- `image/projects/`: sample dune projects baked into `/root/`,
  chosen by KC against the course's fresh-code and domain-overlap
  conventions: `hello/` (30-second first build), `morse/`
  (encoder/decoder, two modules, round-trip tests), `bowling/`
  (ten-pin scorer, branchy; the coverage demo).
- `image/build.sh`: Docker image -> rootfs tar -> fs.json +
  zstd chunk store.
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

## Pinned versions

- Base: `i386/alpine:3.23` (OCaml 5.4.0, dune 3.20.2 from apk).
- v86 repo: commit `e37189a` (tools + BIOS); engine: npm
  `v86@0.5.359` (prebuilt libv86 + v86.wasm; never compiled here).
- bisect_ppx: pinned in the Dockerfile to upstream PR #448's head
  (OCaml 5.4 / ppxlib >= 0.36 port); swap to the opam release
  when it ships.
- opam libraries: ounit2, qcheck (module 9's testing libraries).

Deployed data versions live in the
`fplaunchpad/ocaml-browser-vm` repo (one immutable `vN/` per
build; currently `v3`). After any rebuild here, push a NEW `vN/`
there and bump `DEFAULT_BASE` in `assets/vm/vm-terminal.js`.
