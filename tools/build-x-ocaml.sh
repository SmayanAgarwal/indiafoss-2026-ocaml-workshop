#!/usr/bin/env bash
#
# Rebuild assets/x-ocaml/x-ocaml.js (and the worker) from the
# vendored x-ocaml source in vendor/x-ocaml/. This is the canonical
# path any change in vendor/x-ocaml/src/ (e.g. KC's tooltip-not-
# clipped fix in src/style.css) takes to land in the deployed
# bundle. Without it, a maintainer rebuilding could pick up the
# stale committed binary inside vendor/x-ocaml/ and lose the fix.
#
# Requirements:
# - The vendored x-ocaml submodule is checked out at the nptel
#   branch tip (b32ca84 or later). A fresh clone gets there via:
#     git submodule update --init --recursive
# - An opam switch (typically 5.4.0 for vanilla, 5.2.0+ox for the
#   OxCaml-extended bundle) with the x-ocaml build deps installed.
#   Set X_OCAML_SWITCH to pick a switch; defaults to current.
# - A working dune + js_of_ocaml in that switch.
#
# Usage:
#   bash tools/build-x-ocaml.sh
#       Rebuilds the vanilla bundle under assets/x-ocaml/.
#   X_OCAML_SWITCH=5.4.0 bash tools/build-x-ocaml.sh
#       Same, explicit switch.
#   bash tools/build-x-ocaml.sh worker
#       Also rebuilds the x-ocaml.worker.js (no-effects worker,
#       ~33 MB). Most source changes don't touch the worker, so
#       skip unless you've changed worker/no-effects/*.
#
# OxCaml-extended bundle (assets/x-oxcaml/x-ocaml.js):
#   The OxCaml bundle is built on a different branch / switch and
#   is *not* covered by this script. To rebuild it, switch the
#   submodule to its OxCaml branch and run the upstream
#   build_portable_js_extend.sh script under the 5.2.0+ox switch.
#   The src/style.css fix is shared, so an OxCaml rebuild from the
#   same source tree picks up the tooltip fix automatically.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SRC="$REPO_ROOT/vendor/x-ocaml"
DEST="$REPO_ROOT/assets/x-ocaml"

if [ ! -d "$SRC/src" ]; then
  echo "Vendored x-ocaml missing or not initialised at $SRC." >&2
  echo "Run: git submodule update --init --recursive" >&2
  exit 1
fi

WANT_WORKER=0
for arg in "$@"; do
  case "$arg" in
    worker) WANT_WORKER=1 ;;
  esac
done

if [ -n "${X_OCAML_SWITCH:-}" ]; then
  RUN=(opam exec --switch="$X_OCAML_SWITCH" --)
else
  RUN=()
fi

cd "$SRC"

TARGETS=(x-ocaml.js)
if [ "$WANT_WORKER" = "1" ]; then
  TARGETS+=(x-ocaml.worker.js)
fi

echo "Building ${TARGETS[*]} in $SRC ..."
"${RUN[@]}" dune build "${TARGETS[@]}"

mkdir -p "$DEST"
cp "$SRC/x-ocaml.js" "$DEST/x-ocaml.js"
if [ "$WANT_WORKER" = "1" ]; then
  cp "$SRC/x-ocaml.worker.js" "$DEST/x-ocaml.worker.js"
fi

echo
echo "Installed:"
ls -la "$DEST/x-ocaml.js"
[ "$WANT_WORKER" = "1" ] && ls -la "$DEST/x-ocaml.worker.js"

echo
echo "Sanity-check that the tooltip fix is present in the deployed"
echo "bundle (we expect [max-width: 60ch], not [max-width: 400px]):"
if grep -q 'max-width: 60ch' "$DEST/x-ocaml.js"; then
  echo "  OK: deployed bundle carries the tooltip fix."
else
  echo "  WARN: deployed bundle does NOT carry [max-width: 60ch];" >&2
  echo "  the vendored src/style.css may have regressed." >&2
  exit 2
fi
