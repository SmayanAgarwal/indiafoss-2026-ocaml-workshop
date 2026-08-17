# IndiaFOSS Workshop 2026

Source repository for **Fun and Profit with OCaml**, a workshop being offered at
[IndiaFOSS 2026](https://fossunited.org/indiafoss/2026). The content has been
adapted from [OCaml tutorial - Abstraction 2019](https://github.com/kayceesrk/ocaml-tutorial/tree/master) and the infrastucture from [Functional Programming with OCaml](https://github.com/fplaunchpad/ocaml_nptel) has been used for deployment.

This workshop is tailored towards those who are familiar with programming but
have not written any code using OCaml before. We will go over the basics of
programming in OCaml through the use of expressions, functions, data types and
a few other powerful features common to most functional programming languages
such as pattern matching and higher-order programming.

## What's in here

```
tools/
  nptel-build/                     OCaml binary: .md -> HTML (cmarkit + frontmatter
                                   parser + line-oriented fenced-div preprocessor
                                   + <x-ocaml> cell rendering + dual-mode HTML emit).
  build-site.sh                    Wrapper: builds the binary then renders every
                                   lecture into _site/, plus a landing index.html.
  build-diagrams.sh                pdflatex + pdftocairo pipeline: TikZ -> SVG
                                   for diagrams under assets/diagrams/.
  run-tests.sh                     dune runtest + Playwright smoke check.
  video-pipeline/                  yt-dlp + ffmpeg + mlx-whisper pipeline that
                                   turns the CS3100 YouTube playlist into local
                                   transcripts under _references/_video/.
  playwright-check.mjs             Headless render check used during development.

assets/
  x-ocaml/                         Prebuilt in-browser OCaml WebComponent
                                   (host + worker JS, vanilla OCaml 5.4.0).
  reveal/dist/                     reveal.js 5.x for slide mode.
  css/chapter.css                  Long-form chapter styling, sidebar, prev/next.
  css/slides.css                   Slide-mode overrides for reveal.js.
  diagrams/                        TikZ sources (.tex) + generated SVGs.

vendor/
  x-ocaml/                         Submodule: kayceesrk/x-ocaml @ nptel.
                                   Used only to rebuild the bundles in
                                   assets/x-ocaml/ when needed.

_references/                       Source material consulted by authors.
  textbooks/                       cs3110, RWO v2, Whitington PDF (gitignored).
  profiling_a_programming_language/ Crichton et al. paper (gitignored).
  _video/                          CS3100 transcripts (commit: transcript.md +
                                   slides_with_narration.json; gitignored:
                                   raw .mp4 / .wav / .json).
  cs3100_m20/, cs3100_m25/         Prior-iteration source notebooks (gitignored).

PLAN.md                            Module-by-module mapping from CS3100 to NPTEL.
```

## Build & preview locally

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

## Hosting

`.github/workflows/pages.yml` deploys `_site/` to GitHub Pages on
every push to `main`. After the first push:

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


## Acknowledgements

- [`art-w/x-ocaml`](https://github.com/art-w/x-ocaml) by Arthur
  Wendling: the in-browser OCaml WebComponent that powers every
  runnable cell on the site.
- [Cornell CS3110 textbook](https://cs3110.github.io/textbook/),
  [Real World OCaml v2](https://dev.realworldocaml.org/), and
  John Whitington's *OCaml from the Very Beginning*: the three
  reference texts the lecture material draws on most heavily.
- Crichton et al., *Profiling Programming Language Learning*
  (Brown PLT): the TRPL inline-quiz study that motivated the
  quiz infrastructure.
- The CS3100 students at IIT Madras whose questions over four
  semesters shaped how this material is taught.

## License

Course material distributed under **CC-BY-NC-SA** per the NPTEL
faculty guidelines.
