# Licenses and sources

This course (`Functional Programming with OCaml`, NPTEL July 2026,
KC Sivaramakrishnan, IIT Madras) is licensed under **CC BY-NC-SA 4.0**;
see `LICENSE`. It was prepared with reference to the materials listed
below, each retaining its own license. The course's prose, worked
examples, and quizzes are independent expression of factual material on
OCaml and functional programming; close paraphrase and structural
mirroring have been audited per lecture.

## Course content

CC BY-NC-SA 4.0, per the NPTEL course content requirements.

## Course toolchain

`tools/nptel-build/` (custom static-site toolchain), `tools/quiz-backend/`
(Cloudflare Worker), `tools/build-site.sh`, `tools/video-pipeline/`:
written for this course; ISC.

## Vendored components

- `vendor/x-ocaml/`: art-w/x-ocaml upstream; ISC. See
  `vendor/x-ocaml/LICENSE` and the upstream repository at
  <https://github.com/art-w/x-ocaml>.
- `assets/reveal/`: reveal.js 5.x distribution; MIT. See
  <https://github.com/hakimel/reveal.js>.

## Reference material consulted

Treat the entries below as *consulted* sources. Reading and being
informed by them is fine; close paraphrase is not. Where a license
restricts derivative use, this is noted; where our use approaches the
boundary, an independent-expression check was made for the lecture in
question.

### Cornell CS3110, *OCaml Programming: Correct + Efficient + Beautiful*

- Authors: Michael R. Clarkson, with contributors.
- URL: <https://cs3110.github.io/textbook/>
- License: **CC BY-NC-ND 4.0** (No Derivatives).
- Usage: reference for topic coverage, pedagogical sequence, and
  cross-checking that we are teaching the right things in the right
  order. The ND clause precludes derivative works; the audit confirms
  that the lectures are independent expression of overlapping factual
  material rather than rewrites.

### Real World OCaml, 2nd ed.

- Authors: Yaron Minsky, Anil Madhavapeddy, Jason Hickey.
- URL: <https://dev.realworldocaml.org/>
- Licenses (three, from the book's LICENSE.md):
  - Site-generation code: ISC.
  - **Book prose: CC BY-NC-ND 3.0 US** (NoDerivatives, like CS3110).
  - Code examples in the book: UNLICENSE (public domain; freely
    reusable).
- Usage: reference for idiomatic OCaml, library ecosystem context,
  and industrial-quality code. No prose paraphrased; the prose ND
  clause precludes derivative reuse. Code examples freely reusable
  under UNLICENSE, but we generally use our own examples anyway.

### *OCaml from the Very Beginning*

- Author: John Whitington (Coherent Press).
- License: commercial all-rights-reserved.
- Usage: reference for pacing of introductory material and worked
  exercises. No prose or examples reused. The book influenced the
  shape of M01 and the early M02 lectures (how to introduce simple
  expressions to total beginners); the lectures are independent
  expression.

### CS3100 (KC Sivaramakrishnan, IIT Madras, 2024 to 2025)

- Author: KC Sivaramakrishnan.
- License: KC's own prior course material; freely reused by the
  author for this MOOC.
- Usage: the primary drafting source. The YouTube playlist was
  transcribed into per-lecture transcripts and used to recover
  KC's own spoken explanations, which became the seed for the
  corresponding NPTEL lectures.

### CS6868 OxCaml handout (KC Sivaramakrishnan, IIT Madras, 2026)

- Author: KC Sivaramakrishnan.
- License: KC's own prior course material; freely reused.
- Usage: source for the Modules 9 to 12 (secure-systems) redesign,
  particularly the locality / uniqueness / portability mode material
  in M10.

### *Profiling Programming Language Learning*

- Authors: Will Crichton, Marco Patrignani, Maneesh Agrawala, Shriram
  Krishnamurthi.
- Venue: 2023.
- Usage: methodology source for the inline-quiz design (MCQ format,
  the *Why* explanations, the code-fill-in pattern). Cited as
  methodology; no prose reused.

### Other consulted materials

- The OCaml manual (<https://v2.ocaml.org/manual/>), used as the
  authoritative reference for language behaviour.
- The OCaml `discuss.ocaml.org` "Industrial Users of OCaml" thread,
  used as a source for the contemporary industrial-use list in M01.
- Pierce, *Types and Programming Languages* (2002), cited for the
  let-polymorphism / type-inference framing in M02-L03.
- Hughes, *Why Functional Programming Matters* (1990), cited as a
  foundational pointer in M01-L02.

## Per-lecture attribution

Each lecture closes with a *Sources* footer that lists the materials
consulted for that specific lecture. See any lecture under
`lectures/M*-L*.md` for the canonical format.

## Compatibility with NPTEL's CC BY-NC-SA mandate

NPTEL course content must be CC BY-NC-SA 4.0. This is compatible with:

- Our own original prose, code, and quizzes.
- CS3100 / CS6868 material (KC re-licenses to CC BY-NC-SA for this
  MOOC).
- Stock teaching examples and factual content (no copyright).

It is *not* directly compatible with a CC BY-NC-ND input (such as
CS3110) when the output is judged a derivative work. The mitigation
is the independent-expression test applied per lecture and recorded
in each lecture's *Sources* footer.
