#!/usr/bin/env bash
# Build the i386 Alpine + OCaml rootfs for v86 (9p, chunked, zstd).
# Adapted from v86's tools/docker/alpine/build.sh.
#
# Sources (this directory) are committed; heavy inputs/outputs live
# in an untracked scratch dir (default: _vm-prototype/ at the repo
# root, override with VM_SCRATCH). Run ../setup-scratch.sh once to
# populate the scratch dir with v86 and the prebuilt engine.
set -euo pipefail

cd "$(dirname "$0")"

REPO_ROOT=$(cd ../../.. && pwd)
SCRATCH="${VM_SCRATCH:-$REPO_ROOT/_vm-prototype}"
V86_TOOLS="$SCRATCH/v86/tools"
IMAGES="$SCRATCH/images"
OUT_ROOTFS_TAR="$IMAGES"/ocaml-rootfs.tar
OUT_ROOTFS_FLAT="$IMAGES"/ocaml-rootfs-flat
OUT_FSJSON="$IMAGES"/ocaml-fs.json
CONTAINER_NAME=ocaml-v86
IMAGE_NAME=i386/ocaml-v86

[ -d "$V86_TOOLS" ] || {
    echo "error: $V86_TOOLS not found; run tools/vm-image/setup-scratch.sh first" >&2
    exit 1
}

mkdir -p "$IMAGES"
docker build . --platform linux/386 --rm --tag "$IMAGE_NAME"
docker rm "$CONTAINER_NAME" 2>/dev/null || true
docker create --platform linux/386 -t -i --name "$CONTAINER_NAME" "$IMAGE_NAME"

docker export "$CONTAINER_NAME" -o "$OUT_ROOTFS_TAR"
docker rm "$CONTAINER_NAME"

tar -f "$OUT_ROOTFS_TAR" --delete ".dockerenv" || true

"$V86_TOOLS"/fs2json.py --zstd --out "$OUT_FSJSON" "$OUT_ROOTFS_TAR"

# Regenerate the chunk store from scratch so stale chunks from
# previous builds don't inflate it.
rm -rf "$OUT_ROOTFS_FLAT"
mkdir -p "$OUT_ROOTFS_FLAT"
"$V86_TOOLS"/copy-to-sha256.py --zstd "$OUT_ROOTFS_TAR" "$OUT_ROOTFS_FLAT"

echo "Created:"
du -sh "$OUT_ROOTFS_TAR" "$OUT_ROOTFS_FLAT" "$OUT_FSJSON"
