#!/usr/bin/env bash
# Populate the untracked scratch dir with the pinned third-party
# inputs the VM image build needs: the v86 repo (for the 9p
# conversion tools and BIOS blobs) and the prebuilt v86 engine from
# npm (libv86 + v86.wasm; we never compile v86 ourselves).
set -euo pipefail

V86_COMMIT=e37189a4ad6ce4138e7168508f07553d0d3b6b3f
V86_NPM_VERSION=0.5.359

cd "$(dirname "$0")"
REPO_ROOT=$(cd ../.. && pwd)
SCRATCH="${VM_SCRATCH:-$REPO_ROOT/_vm-prototype}"
mkdir -p "$SCRATCH"
cd "$SCRATCH"

if [ ! -d v86 ]; then
    git clone https://github.com/copy/v86.git
    git -C v86 checkout "$V86_COMMIT"
fi

if [ ! -f v86/build/v86.wasm ]; then
    curl -fsSL -o v86-npm.tgz \
        "https://registry.npmjs.org/v86/-/v86-$V86_NPM_VERSION.tgz"
    mkdir -p engine v86/build
    tar xzf v86-npm.tgz -C engine --strip-components=1
    cp engine/build/libv86.js engine/build/libv86.mjs \
       engine/build/v86.wasm engine/build/v86-fallback.wasm v86/build/
fi

cp "$REPO_ROOT/tools/vm-image/prototype.html" .

echo "scratch ready at $SCRATCH"
echo "next: bash $REPO_ROOT/tools/vm-image/image/build.sh"
