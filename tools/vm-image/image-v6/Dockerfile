# Candidate image v6: v5 plus the MirageOS unikernel workflow for
# module 12. Derives FROM the locally built v5 image (i386/ocaml-v86,
# see ../image/Dockerfile) so the expensive v5 opam layer is reused
# as-is. Because build.sh produces the rootfs with `docker export`
# (flattened), the re-trim at the end of THIS file genuinely shrinks
# the chunk store even though we delete files created in v5 layers.
#
# What v6 adds, all baked at build time (the VM is offline):
#   - the mirage CLI 4.11.0 (bytecode; OCaml 5 has no 32-bit native
#     backend) plus its deps, incl. opam-monorepo, in the existing
#     ocaml-system opam switch;
#   - /root/m12/hello: a hello unikernel already configured with
#     `mirage configure -t unix`, with the duniverse/ vendored by
#     `make depend` at image-build time (students cannot run
#     `make depend` in the VM: no network) and _build pre-baked so
#     the first in-VM rebuild after editing unikernel.ml is
#     incremental.
FROM i386/ocaml-v86

# v5 trims /root/.opam/repo (the 178 MB index) at the end of its
# build, so a derived image must restore the repository before any
# opam install. Re-add + update, install, then re-trim below.
RUN (opam repo add default https://opam.ocaml.org --all-switches \
     || opam repo set-url default https://opam.ocaml.org) \
    && opam update

# The mirage CLI and opam-monorepo. Everything is bytecode on this
# 32-bit switch; the CLI itself runs fine as bytecode. Keep this
# layer above the COPY of the project so config edits do not
# invalidate the (qemu-emulated, slow) install.
# pkgconf: opam-monorepo depends on conf-pkg-config.
# OCAMLPATH: on an ocaml-system switch the stdlib is /usr/lib/ocaml
# (apk) while opam libraries land in the switch lib dir, so dune
# inside opam package builds only finds already-installed opam libs
# via findlib or OCAMLPATH. opam runs jobs in parallel, and ipaddr/
# angstrom raced ahead of ocamlfind's install and failed with
# Library "bigstringaf"/"macaddr.top" not found. Pin the path here
# (same value /etc/profile.d/opam.sh exports at VM runtime) and
# install ocamlfind first for good measure.
ENV OCAMLPATH=/root/.opam/ocaml-system/lib
RUN apk add pkgconf
RUN opam install -y ocamlfind
RUN opam install -y mirage.4.11.0

# The module 12 unikernel project.
COPY projects/m12/ /root/m12/

# Configure for the unix target, vendor the monorepo (network is
# available at image-build time only), and pre-build. The generated
# Makefile's `make depend` = lock + install-switch + pull;
# install-switch's depext step uses apk here (fine on Alpine).
# `make build` = dune build --profile release --root . ./dist; with
# no ocamlopt on the switch, dune builds a bytecode executable with
# a custom runtime (gcc + musl-dev already in the image, same
# mechanism as every other bytecode exe in the VM).
RUN . /etc/profile.d/opam.sh && cd /root/m12/hello \
    && mirage configure -t unix
RUN . /etc/profile.d/opam.sh && cd /root/m12/hello \
    && make depend
RUN . /etc/profile.d/opam.sh && cd /root/m12/hello \
    && make build
# Smoke-test the unikernel inside the build (4 log lines, ~4 s),
# then verify the hvt configure-only flow works offline and leave
# the tree configured for unix (the state students boot into).
RUN . /etc/profile.d/opam.sh && cd /root/m12/hello \
    && ./dist/hello \
    && mirage configure -t hvt \
    && grep -q "Solo5_os.Main.run" mirage/main.ml \
    && mirage configure -t unix \
    && grep -q "Unix_os.Main.run" mirage/main.ml \
    && make build
# `make depend` adds the dune-universe overlay repos and removes
# them again, but remove defensively in case a failed retry left
# them behind; then re-trim everything v5 trims (the repo index is
# back, plus new download-cache/sources/build state from the mirage
# install). Also re-assert the no-bytecode-dune-binary policy: PATH
# must keep resolving dune to the native apk one.
RUN opam repo remove --all-switches opam-overlays mirage-overlays 2>/dev/null; \
    opam clean -a -y && \
    rm -rf /root/.opam/repo \
           /root/.opam/download-cache \
           /root/.opam/*/.opam-switch/sources \
           /root/.opam/*/.opam-switch/build \
           /root/.opam/*/.opam-switch/backup \
           /root/.opam/*/man \
           /root/.cache \
           /var/cache/apk/*
RUN find /root/.opam /usr/lib/ocaml \( -name '*.cmt' -o -name '*.cmti' \) -delete 2>/dev/null; \
    rm -f /root/.opam/ocaml-system/bin/dune
