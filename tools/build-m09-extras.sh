#!/bin/bash
# Build the M09 in-browser extension bundle. Adds QCheck (qcheck-core)
# and OUnit2 to the running vanilla x-ocaml toplevel via the
# `--toplevel-extend --export units.txt` recipe described in
#   https://kcsrk.info/ocaml/oxcaml/modes/2026/05/10/shrinking-the-oxcaml-bundle/
#
# Output: assets/x-ocaml/m09-extras.js (~600 KB after cmi embedding)
# Load via: <script ... src-load="/assets/x-ocaml/m09-extras.js"> on
# the host page; added to lecture HTML by tools/nptel-build/lib/emit.ml
# for M09 lectures only (so M01-M08 stay slim).
#
# Requires the patched js_of_ocaml from
# https://github.com/kayceesrk/js_of_ocaml/tree/kc-toplevel-extend
# checked out at ~/repos/js_of_ocaml. The patch adds `--toplevel-extend`
# which makes the bundle composable (kind=cma) instead of clobbering
# the toplevel (kind=exe).
#
# Run from the repo root:
#   $ bash tools/build-m09-extras.sh
set -eu

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$REPO_ROOT/assets/x-ocaml/m09-extras.js"
FORK="$HOME/repos/js_of_ocaml"
JSOO="$FORK/_build/default/compiler/bin-js_of_ocaml/js_of_ocaml.exe"
JSOO_LISTUNITS="$FORK/_build/default/toplevel/bin/jsoo_listunits.exe"

[ -x "$JSOO" ] || { echo "missing $JSOO; build with: cd $FORK && dune build compiler/bin-js_of_ocaml/js_of_ocaml.exe toplevel/bin/jsoo_listunits.exe"; exit 1; }
[ -x "$JSOO_LISTUNITS" ] || { echo "missing $JSOO_LISTUNITS; same build step as above"; exit 1; }
ocamlfind query qcheck-core >/dev/null 2>&1 || { echo "qcheck-core not installed: opam install qcheck-core"; exit 1; }
ocamlfind query ounit2      >/dev/null 2>&1 || { echo "ounit2 not installed: opam install ounit2"; exit 1; }

QC=$(ocamlfind query qcheck-core)
OU=$(ocamlfind query ounit2)

workdir=$(mktemp -d)
trap "rm -rf $workdir" EXIT

# 1. Stub bytecode that pulls qcheck-core and ounit2 onto the link line.
echo 'let () = ()' > "$workdir/stub.ml"
ocamlfind ocamlc -g -package qcheck-core,ounit2 -linkpkg -linkall \
  "$workdir/stub.ml" -o "$workdir/stub.byte"

# 2. List the units that should remain visible to the toplevel after
#    cross-cma DCE. Pass the cmis directly because the patched
#    jsoo_listunits doesn't resolve findlib package names in this switch.
$JSOO_LISTUNITS -o "$workdir/units.txt" \
  "$QC/qCheck.cmi" "$QC/qCheck2.cmi" \
  "$OU/oUnit.cmi"  "$OU/oUnit2.cmi"

# 3. Embed the cmis so the toplevel can elaborate hover types and
#    `open` declarations against the QCheck/OUnit2 signatures.
file_args=()
for f in "$QC"/qCheck.cmi "$QC"/qCheck2.cmi "$OU"/oUnit.cmi "$OU"/oUnit2.cmi; do
  file_args+=("--file=$f:/static/cmis/")
done

# 4. Build the extension bundle.
$JSOO --toplevel --toplevel-extend --export="$workdir/units.txt" \
  "${file_args[@]}" \
  "$workdir/stub.byte" -o "$OUT"

ls -lh "$OUT"
