# i386 Alpine image for v86, with the OCaml toolchain baked in.
# Based on v86's tools/docker/alpine/Dockerfile (BSD-2-Clause).
FROM docker.io/i386/alpine:3.23

ENV KERNEL=virt
# ocaml5 = OCaml 5.4.0 (bytecode-only on 32-bit x86); dune 3.20.
# ocaml5-compiler-libs: Alpine splits compiler-libs out of ocaml5;
# ppxlib's dependency chain (ocaml-compiler-libs, stdlib-shims)
# fails without it ("Library compiler-libs.bytecomp not found").
# musl-dev: C headers for dune's custom-runtime linking of bytecode
# executables (gcc itself comes in via ocaml5's dependencies).
# nano + less for editing/paging inside the VM.
ENV ADDPKGS="ocaml5 ocaml5-compiler-libs dune musl-dev nano less"

RUN apk add openrc alpine-base agetty alpine-conf linux-$KERNEL linux-firmware-none $ADDPKGS

RUN sed -i 's/getty 38400 tty1/agetty --autologin root tty1 linux/' /etc/inittab
RUN echo 'ttyS0::respawn:/sbin/agetty --autologin root -s ttyS0 115200 vt100' >> /etc/inittab
RUN echo "root:" | chpasswd

# Docker bind-mounts /etc/hostname during build, so writes to it do
# not survive into the exported rootfs (it ends up holding the build
# container's ID). Set the hostname from /etc/profile instead; the
# serial getty also races the openrc hostname service, so this is
# the reliable path for the autologin shell's prompt.
RUN echo 'hostname ocaml-vm' >> /etc/profile

# opam layer: libraries that are not in apk get baked in here, at
# image-build time (the VM has no network at runtime). The switch
# reuses the apk OCaml via ocaml-system, so no compiler build.
# Keep this layer above the COPY of sample projects so project
# edits don't invalidate the (expensive, qemu-emulated) opam build.
RUN apk add opam curl git make patch
RUN opam init -a -y --disable-sandboxing --compiler=ocaml-system
# Pin the switch's dune to exactly the apk dune version. Students
# run the NATIVE apk dune (fast under emulation; the opam one is
# bytecode), and an older dune cannot read `dune-package` metadata
# written by a newer one, so the versions must match.
RUN opam pin add -y dune $(dune --version)
# bisect_ppx has no OCaml 5.4-compatible release: 2.8.3 caps
# ppxlib < 0.36, and master still uses the pre-5.2 Pexp_function
# AST node, so it fails against ppxlib >= 0.36. The port is PR
# aantron/bisect_ppx#448 (patricoferris, branch "5.2"); pin its
# head commit. Swap to the official release when #448 merges.
RUN opam pin add -y bisect_ppx \
    git+https://github.com/patricoferris/bisect_ppx.git#7061d643ff492b0045796357ee6917ded21fb1f0
# Testing libraries used by module 9: OUnit2 for unit-test suites,
# QCheck for property-based testing.
RUN opam install -y ounit2 qcheck
# Capture the opam environment as a static profile script BEFORE
# trimming: `opam env` itself wants the repo index we delete below.
RUN opam env > /etc/profile.d/opam.sh && \
    echo 'export OCAMLPATH=/root/.opam/ocaml-system/lib${OCAMLPATH:+:$OCAMLPATH}' \
      >> /etc/profile.d/opam.sh
# Trim what students never need. Because the rootfs is produced by
# `docker export` (flattened), deletions here genuinely shrink the
# chunk store, unlike in layered images. Sizes at last audit:
# opam repo index 178 MB, .cmt/.cmti 49 MB, apk cache 3 MB.
RUN opam clean -a -y && \
    rm -rf /root/.opam/repo \
           /root/.opam/download-cache \
           /root/.opam/*/.opam-switch/sources \
           /root/.opam/*/.opam-switch/build \
           /root/.opam/*/.opam-switch/backup \
           /root/.opam/*/man \
           /root/.cache \
           /var/cache/apk/*
RUN find /root/.opam /usr/lib/ocaml \( -name '*.cmt' -o -name '*.cmti' \) -delete
# Drop the switch's (bytecode) dune binary so PATH falls through to
# the native apk dune; OCAMLPATH lets it see the opam libraries.
RUN rm -f /root/.opam/ocaml-system/bin/dune

# Sample dune projects for students to build.
COPY projects/ /root/

# Pre-bake bowling's INSTRUMENTED build: linking the per-project
# ppx driver against ppxlib takes ~90 s inside the emulated VM,
# which is a rough first experience for the L03 coverage loop.
# With the artifacts in _build, the student's first
# `dune runtest --instrument-with bisect_ppx` is incremental
# (seconds). Drop the .coverage files the bake's test run wrote:
# students should start from a clean slate. morse and hello stay
# unbaked deliberately, so building a project from scratch (and
# its honest cost) can still be experienced there.
RUN . /etc/profile.d/opam.sh && cd /root/bowling && \
    dune runtest --instrument-with bisect_ppx && \
    rm -f bisect*.coverage

# Pre-run the streak project's partial suite under instrumentation
# (the M09-L03 coverage demo: longest_streak, the lecture's own
# glass-box example, with a deliberately partial three-row suite so
# the report has red to chase). dune writes the .coverage under
# _build/default/test/, which the `rm bisect*.coverage` below does
# NOT match, so the baked record survives: on boot the student runs
# `bisect-ppx-report summary` and sees 5/6 immediately, no `dune`
# and no `--force`. Adding a run-bearing row and re-running (dune
# re-runs the changed suite) reaches 6/6.
RUN . /etc/profile.d/opam.sh && cd /root/streak && \
    dune runtest --instrument-with bisect_ppx && \
    rm -f bisect*.coverage

# https://wiki.alpinelinux.org/wiki/Alpine_Linux_in_a_chroot#Preparing_init_services
RUN for i in devfs dmesg mdev hwdrivers; do rc-update add $i sysinit; done
RUN for i in hwclock modules sysctl hostname syslog bootmisc; do rc-update add $i boot; done
RUN rc-update add killprocs shutdown

# Flush dirty pages promptly (~2 s instead of the default ~30 s).
# The host page reads VM files via the 9p backend (the coverage
# report viewer); with cache=loose, lazy writeback would make
# freshly written files invisible to it for up to half a minute.
RUN printf 'vm.dirty_expire_centisecs = 200\nvm.dirty_writeback_centisecs = 200\n' \
      > /etc/sysctl.d/99-writeback.conf

# Generate initramfs with 9p modules
RUN mkinitfs -F "base virtio 9p" $(cat /usr/share/kernel/$KERNEL/kernel.release)
