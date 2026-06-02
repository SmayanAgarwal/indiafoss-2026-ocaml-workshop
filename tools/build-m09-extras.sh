#!/bin/bash
# Build the M09 in-browser extension bundle. Adds QCheck (qcheck-core)
# plus QCheck_runner (qcheck, alcotest-backed) plus OUnit2 to the
# running vanilla x-ocaml toplevel via the
# `--toplevel-extend --export units.txt` recipe described in
#   https://kcsrk.info/ocaml/oxcaml/modes/2026/05/10/shrinking-the-oxcaml-bundle/
#
# Output: assets/x-ocaml/m09-extras.js (~450 KB)
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
ocamlfind query qcheck-core        >/dev/null 2>&1 || { echo "qcheck-core not installed: opam install qcheck-core"; exit 1; }
ocamlfind query qcheck-core.runner >/dev/null 2>&1 || { echo "qcheck-core.runner not installed (part of qcheck-core opam package)"; exit 1; }
ocamlfind query qcheck             >/dev/null 2>&1 || { echo "qcheck not installed: opam install qcheck (pulls in alcotest-backed runner)"; exit 1; }
ocamlfind query ounit2             >/dev/null 2>&1 || { echo "ounit2 not installed: opam install ounit2"; exit 1; }

QC=$(ocamlfind query qcheck-core)
QCR=$(ocamlfind query qcheck-core.runner)
QCFULL=$(ocamlfind query qcheck)
OU=$(ocamlfind query ounit2)

workdir=$(mktemp -d)
trap "rm -rf $workdir" EXIT

# 1. Stub bytecode that pulls qcheck-core, qcheck-core.runner, qcheck
#    (alcotest-backed) and ounit2 onto the link line. The alcotest
#    backend lets students use QCheck_runner.run_tests_main even though
#    the in-browser worker has no terminal; alcotest's output just
#    lands in the cell's stdout pane.
echo 'let () = ()' > "$workdir/stub.ml"
ocamlfind ocamlc -g \
  -package qcheck-core,qcheck-core.runner,qcheck,ounit2 \
  -linkpkg -linkall \
  "$workdir/stub.ml" -o "$workdir/stub.byte"

# 2. List the units that should remain visible to the toplevel after
#    cross-cma DCE. Pass the cmis directly because the patched
#    jsoo_listunits doesn't resolve findlib package names in this switch.
$JSOO_LISTUNITS -o "$workdir/units.txt" \
  "$QC/qCheck.cmi" "$QC/qCheck2.cmi" \
  "$QCR/qCheck_base_runner.cmi" \
  "$QCFULL/qCheck_runner.cmi" \
  "$OU/oUnit.cmi"  "$OU/oUnit2.cmi"

# 3. Build the extension bundle.
#
#    Do NOT pass explicit --file=<cmi>:/static/cmis/ embeds here:
#    --toplevel already auto-embeds the cmis of the exported units,
#    and a second registration of the same path makes the bundle
#    raise Sys_error("... file already exists") at load time, which
#    aborts the remaining module initialisers (QCheck/OUnit2 then
#    show up as interface-only: "Reference to undefined compilation
#    unit"). Hover/type elaboration works off the auto-embedded
#    copies.
$JSOO --toplevel --toplevel-extend --export="$workdir/units.txt" \
  "$workdir/stub.byte" -o "$OUT"

# 4. Prepend a runtime shim. The vanilla worker runtime does not
#    provide caml_unix_gethostname, but ounit2's OUnitUtils calls
#    Unix.gethostname at module-init time; without the shim the
#    extras load dies partway (TypeError) and OUnit2 never
#    registers. Any hostname string will do.
shim='// Prepended by tools/build-m09-extras.sh: the vanilla worker
// runtime lacks a few Unix primitives that ounit2 calls:
// gethostname at module init (OUnitUtils), environment when
// run_test_tt_main starts (OUnitConf). Stub both so OUnit2 loads
// and its runner works in the browser toplevel.
(function (g) {
  var r = g.jsoo_runtime;
  if (!r) return;
  if (!r.caml_unix_gethostname) {
    r.caml_unix_gethostname = function () { return "browser"; };
  }
  if (!r.caml_unix_environment) {
    r.caml_unix_environment = function () { return [0]; };
  }
})(globalThis);'
printf '%s\n' "$shim" | cat - "$OUT" > "$OUT.tmp" && mv "$OUT.tmp" "$OUT"

ls -lh "$OUT"
