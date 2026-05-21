# Project notes for Claude

NPTEL "Functional Programming with OCaml" course materials. Twelve
modules: M01-M08 functional programming, M09-M12 secure systems
(testing, memory safety, OxCaml, unikernels). Recording starts
2026-05-20 at the NPTEL studio.

For the design rationale, see the plan files (or ask the user).
The rest of this file is operational conventions.

## Author-comment workflow (KC drops notes, Claude sweeps)

KC leaves inline comments in any markdown source (lectures,
READMEs, plans). Claude sweeps and addresses them in batches so
KC does not have to interrupt the agent mid-task.

**Markers** (HTML comments, stripped by cmarkit and the build
pipeline, so they never appear in rendered output):

- `<!-- KC: <note> -->`: silent fix request. Address it, then
  remove the comment.
- `<!-- KC?: <question> -->`: KC wants an answer, not a silent
  fix. Reply by editing the comment to
  `<!-- KC?: <question> | claude: <answer> -->`, or by writing
  the answer in a follow-up chat message and removing the comment.
- `<!-- KC!: <blocker> -->`: must resolve before recording the
  lecture. Treat as priority; never leave one of these unresolved
  across sessions.

**Sweep command:**

```sh
grep -rEn '<!--[[:space:]]*KC[!?]?:' lectures/ tools/ assets/ README.md \
  2>/dev/null
```

(The pattern tolerates `<!-- KC:` and `<!--KC:` with or without
the space after `<!--`.)

Run this at the start of a session, when KC says "sweep", or
when finishing other work that may have created context for an
older comment.

**Loop:** walk matches top-to-bottom, edit the file, remove the
comment as you address it. If a comment turns out to be ambiguous
or you disagree, do not silently fix: convert it to `KC?:` form
with your question (or surface in chat).

## Style

- No em-dashes (`--` digram or `—` character) in prose. Use
  colons, semicolons, parens, commas, or separate sentences.
  Exceptions: CLI flag names (`--dce`), markdown table
  separators, YAML front-matter delimiters.
- Lectures wrap prose at ~70 columns (matches the established
  M01-M08 layout).
- Lecture markdown uses Pandoc-style fenced divs (`:::slide`,
  `:::subslide`, `:::fragment`, `:::notes`, `:::quiz mcq id=`,
  `:::quiz code id=`). See an existing lecture for the pattern.
- Commit messages: no `Co-Authored-By: Claude` trailer.

## Toolchain quick reference

- Build site: `bash tools/build-site.sh` (set `COPY_ASSETS=1`
  to also refresh `_site/assets/`).
- Local server for browser checks: a Python http.server on
  `:8765` or `:8766` is often already running; check with
  `lsof -nP -iTCP -sTCP:LISTEN | grep 87`.
- Per-module in-browser bundles (see `tools/nptel-build/lib/emit.ml`):
  - M09 routes to `assets/x-ocaml/` with `m09-extras.js`
    extension (QCheck + OUnit2).
  - M11 routes to `assets/x-oxcaml/` (large OxCaml bundle).
  - Other modules route to plain `assets/x-ocaml/`.
- mdx validation: `dune runtest` (M09 excluded; M11/M12 cells
  marked appropriately).

## Where things live

- Lectures: `lectures/MNN-Lnn-<slug>.md`.
- Plans: `/Users/kc/.claude/plans/`.
- References (gitignored): `_references/textbooks/`,
  `_references/_video/`.
- Licensing audit (gitignored, local-only): `LICENSING_AUDIT.md`.
- Recording-time estimates: `RECORDING-ESTIMATES.md`.

## What not to do without asking

- Do not commit `LICENSING_AUDIT.md` or anything under
  `_references/textbooks/` or `_references/_video/*.mp4`.
- Do not push to `main` after non-trivial restructuring without
  showing the diff first.
- Do not skip OCaml/OxCaml cells just because they raise compile
  errors: compile errors are often the point of the lecture. Use
  in-memory mocks rather than `skip` when an external dep (Unix,
  filesystem) is the only obstacle.
