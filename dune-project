(lang dune 3.17)

(using mdx 0.4)

(name nptel-ocaml)

(generate_opam_files true)

; Records the toolchain executably. The leaf packages below are what
; the lecture mdx cells need on the *default* switch (M01-M10, M12,
; and the M03/M05/M09 practice worksheets): mdx for the code blocks,
; and qcheck/ounit2 for the M09 testing cells. `opam install . --deps-only`
; installs them. M11 (OxCaml) validates on a separate 5.2.0+ox switch
; used bare (no extra packages); see tools/setup-switch.sh.
(package
 (name nptel-ocaml)
 (synopsis "Functional Programming with OCaml: NPTEL lecture sources and toolchain")
 (description
  "Lecture sources, the static-site toolchain, and the in-browser OCaml/OxCaml notebooks for the NPTEL course 'Functional Programming with OCaml'. This package declares only the leaf dependencies needed to validate the lecture code blocks under ocaml-mdx.")
 (depends
  (ocaml (>= 5.2.0))
  (mdx (>= 2.4))
  qcheck
  qcheck-core
  ounit2))
