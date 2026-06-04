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
#    unit"). The cmis the toplevel needs to elaborate the loaded
#    signatures (so hover/type queries resolve QCheck/OUnit2 names)
#    are the auto-embedded copies.
RAW="$workdir/portable_raw.js"
$JSOO --toplevel --toplevel-extend --export="$workdir/units.txt" \
  "$workdir/stub.byte" -o "$RAW"

# 4. Assemble the final bundle from three prepended/wrapped pieces:
#
#    (a) A Unix-primitive shim. The vanilla worker runtime does not
#        provide caml_unix_gethostname, but ounit2's OUnitUtils calls
#        Unix.gethostname at module-init time; without the shim the
#        extras load dies partway (TypeError) and OUnit2 never
#        registers. Same for caml_unix_environment at run_test_tt_main.
#        Any hostname string will do.
#
#    (b) A DLS-preserving harness around the bundle's IIFE. The bundle
#        re-runs stdlib's module init when it loads, and
#        Stdlib__Domain.DLS's `let key_counter = Atomic.make 0`
#        re-allocates the DLS key counter from zero. The bundle's
#        Format.stdbuf_key then lands at a low DLS index the host had
#        already assigned to *its* Format.stdbuf_key, and DLS.set
#        overwrites the host's entry in the shared caml_domain_dls
#        array. The host's Format.flush_str_formatter then reads the
#        bundle's empty buffer, so merlin's type-enclosing printer
#        (which flushes through Format.str_formatter) returns "" for
#        every query and hover-on-identifier tooltips come up blank.
#        Snapshot the host's DLS array before the bundle runs and
#        restore the host-owned slots afterwards; the bundle's new
#        high-index slots are left alone. This mirrors the fix in
#        x-ocaml's build_portable_js_extend.sh (oxcaml branch).
unix_shim='// Prepended by tools/build-m09-extras.sh: the vanilla worker
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

dls_pre='// DLS-preserving harness (see build-m09-extras.sh step 4b):
// snapshot the host toplevel'\''s Domain.DLS slots before the bundle
// re-runs stdlib init, so merlin'\''s Format.str_formatter survives.
(function (globalThis) {
  var rt = globalThis.jsoo_runtime;
  var snapshot = null;
  if (rt && rt.caml_domain_dls_get) {
    var saved = rt.caml_domain_dls_get(0);
    snapshot = [];
    for (var i = 0; i < saved.length; i++) snapshot[i] = saved[i];
  }
  try {'

dls_post='  } finally {
    if (rt && rt.caml_domain_dls_get && snapshot) {
      var cur = rt.caml_domain_dls_get(0);
      for (var i = 0; i < snapshot.length; i++) {
        if (snapshot[i] !== undefined) cur[i] = snapshot[i];
      }
    }
  }
}(globalThis));'

{
  printf '%s\n' "$unix_shim"
  printf '%s\n' "$dls_pre"
  cat "$RAW"
  printf '%s\n' "$dls_post"
} > "$OUT"

ls -lh "$OUT"
