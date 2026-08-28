Source repository for [Fun and Profit with
OCaml](https://fplaunchpad.org/indiafoss-2026-ocaml-workshop/), a workshop being
offered at IndiaFOSS 2026.

## Build & preview locally

If you wish to adapt this content and test it locally before deployment:

```sh
opam switch create . 5.4.0   # only the first time
opam install -y cmarkit fpath alcotest mdx

# build the toolchain + render every lecture into _site/
tools/build-site.sh

# preview
python3 -m http.server 8765
# open http://localhost:8765/_site/M01-L01-course-intro.html
# or http://localhost:8765/_site/ for the landing page
```

## Using GitHub for hosting

`.github/workflows/pages.yml` deploys `_site/` to GitHub Pages on
    every push to the branch specified in `branches`. After the first push:

1. On GitHub: **Settings → Pages**.
2. Under **Build and deployment**, set **Source** to **GitHub Actions**.
3. Wait for the first workflow run to finish; the site URL appears
   at the top of the Pages settings page.

The workflow does not build `vendor/x-ocaml`; it uses the prebuilt
bundles already committed under `assets/x-ocaml/`.


## Learn more about OCaml

- The OCaml language home page: <https://ocaml.org/>. Install
  instructions, the language manual, and the ecosystem of libraries
  and tools.
- [Functional Programming with OCaml](https://github.com/fplaunchpad/ocaml_nptel), a 12-week NPTEL course
- [Academic research using the OCaml language](https://ocaml.org/academic-users)
- Tools that comprise the [OCaml platform](https://ocaml.org/platform)


## Acknowledgements


- [Functional Programming in OCaml" course materials for NPTEL](https://github.com/fplaunchpad/ocaml_nptel)
- [`art-w/x-ocaml`](https://github.com/art-w/x-ocaml) by Arthur
  Wendling: the in-browser OCaml WebComponent that powers every
  runnable cell on the site.
- [Cornell CS3110 textbook](https://cs3110.github.io/textbook/)
-[Real World OCaml v2](https://dev.realworldocaml.org/)

## License

Course material distributed under **CC-BY-NC-SA** per the NPTEL
faculty guidelines.
