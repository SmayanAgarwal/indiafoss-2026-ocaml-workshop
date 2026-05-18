# OCaml NPTEL course

Source repository for **Functional Programming with OCaml**, a 12-week
NPTEL MOOC taught by KC Sivaramakrishnan at IIT Madras. The first
eight weeks cover functional programming in OCaml; the final four
turn to secure systems software (runtime, memory safety, unikernels,
concurrency).

Course launches on SWAYAM/NPTEL in **July 2026**.

## Status

Toolchain complete; lectures for Module 1 (L1-L3) drafted. See
[`PLAN.md`](PLAN.md) for the module-by-module mapping from the source
CS3100 lectures to the new 20-30 min NPTEL videos.

## What's in here

```
lectures/
  M01-L01-course-intro.md      Markdown source for each NPTEL lecture
  M01-L02-why-fp.md            (one .md = one ~25 min video = one webpage)
  M01-L03-ocaml-tour.md
  modules.txt                  Module titles for the sidebar

tools/
  nptel-build/                 OCaml binary: .md -> HTML (cmarkit + frontmatter
                               + fenced divs for slides + <x-ocaml> cells)
  build-site.sh                Wrapper: build the whole _site/
  run-tests.sh                 dune runtest + playwright e2e
  video-pipeline/              yt-dlp + ffmpeg + mlx-whisper pipeline that
                               turns the CS3100 YouTube playlist into local
                               transcripts under _references/_video/

assets/
  x-ocaml/                     Prebuilt in-browser OCaml WebComponent
                               (host + worker JS, vanilla 5.4.0)
  reveal/dist/                 reveal.js for slide mode
  css/                         Chapter view and slide-mode stylesheets

vendor/
  x-ocaml/                     Submodule: kayceesrk/x-ocaml, branch `nptel`
                               (vanilla 5.4.0, with absolute_url fix and
                               connectedCallback guard). Used only when
                               rebuilding the bundles in assets/x-ocaml/.

PLAN.md                        3100 -> NPTEL lecture mapping
_references/_video/            Transcripts of the CS3100 lectures (.md only;
                               video.mp4, audio.wav, transcript.json are
                               gitignored and regenerable via the pipeline)
```

## Authoring a lecture

Each lecture is one markdown file `lectures/M<nn>-L<nn>-<slug>.md` with
a YAML frontmatter block (title, week, lecture_no, concepts, keywords,
activity_question, reading). The body is CommonMark plus:

- ` ```ocaml ` fenced code blocks render as `<x-ocaml>` runnable cells
- `:::slide ... :::` blocks become slides in reveal.js mode
- `:::notes ... :::` blocks are speaker notes
- `:::fragment ... :::` blocks are progressive reveals inside a slide

See [`M01-L01-course-intro.md`](lectures/M01-L01-course-intro.md) for
a worked example.

## Build & preview locally

```sh
opam switch create . 5.4.0   # only the first time
opam install -y cmarkit fpath alcotest

# build the toolchain + render every lecture into _site/
tools/build-site.sh

# preview
python3 -m http.server 8765 --directory .
# open http://localhost:8765/_site/W01-L01-course-intro.html
```

## Tests

```sh
tools/run-tests.sh
```

Runs the OCaml unit + integration tests (`dune runtest`) and a
Playwright end-to-end check that loads the smoke fixture in a real
browser, exercises slide navigation, run-all / clear-all / reset, and
verifies no console errors.

## Hosting

`.github/workflows/pages.yml` deploys `_site/` to GitHub Pages on every
push to `main`. After the first push:

1. On GitHub: **Settings → Pages**.
2. Under **Build and deployment**, set **Source** to **GitHub Actions**.
3. Wait for the first workflow run to finish; the site URL appears at
   the top of the Pages settings page.

The workflow does not build `vendor/x-ocaml`; it uses the prebuilt
bundles already committed under `assets/x-ocaml/`.

## Acknowledgements

- [`art-w/x-ocaml`](https://github.com/art-w/x-ocaml) by Arthur
  Wendling: the in-browser OCaml WebComponent that powers every
  runnable cell on the site.
- [Cornell CS3110 textbook](https://cs3110.github.io/textbook/) and
  [Real World OCaml](https://dev.realworldocaml.org/): the two
  reference texts the lecture material draws on.
- The CS3100 students at IIT Madras whose questions over four
  semesters shaped how this material is taught.

## License

Course material distributed under **CC-BY-NC-SA** per the NPTEL
faculty guidelines.
