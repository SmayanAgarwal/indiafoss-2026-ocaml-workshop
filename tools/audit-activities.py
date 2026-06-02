#!/usr/bin/env python3
"""Audit each lecture's `:::quiz code` activity against its chapter
prose, looking for the M07-L01 `make_counter`==`dispense` and
M05-L04 `sign`==`sign` failure mode: the chapter walks a function
through, and then the activity asks the student to write the same
function.

Heuristic:

  1.  For each `:::quiz code` block, identify the *asked* function
      as the first non-`failwith` `let NAME ...` in the starter.
  2.  Scan chapter-prose ocaml cells (everything outside
      `:::slide`, `:::quiz`, `:::solution`) that appear *before*
      the quiz block.
  3.  If any such cell defines `let NAME` with a body that is not
      just `failwith "not implemented"`, flag the lecture.

Exit code: 0 if no violations, 1 if any.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path


LECTURES_DIR = Path(__file__).resolve().parent.parent / "lectures"

# Names that are commonly test-harness scaffolding and aren't the
# activity's asked function. The script also rejects single-letter
# names since those are almost always test variables.
HARNESS_NAMES = {"check", "main", "ans", "result", "tests"}

# (lecture_filename, asked_function) pairs that are deliberate
# "same pattern, different ADT" extensions rather than literal
# duplicates. Reviewed by hand.
ALLOWLIST = {
    # Chapter walks `command_to_string` through for a hashtable
    # model. Activity asks the student to write a parallel
    # `command_to_string` for a stack -- different ADT, same
    # model-based-testing pattern. Natural extension per
    # feedback-activity-fresh-code.
    ("M09-L07-model-based-testing.md", "command_to_string"),
    # Chapter walks `rep_ok` through for the Rational module
    # (predicate: nonzero denominator). Activity asks for a
    # `rep_ok` for an interval record (predicate: lo <= hi,
    # with the lo = hi boundary as the teaching point) --
    # different ADT, same CS3110 rep_ok convention, whose
    # *name* is part of what is being taught.
    ("M09-L02-specifications-invariants.md", "rep_ok"),
}

LET_RE = re.compile(r"^\s*let(?:\s+rec)?\s+([a-zA-Z_][a-zA-Z_0-9']*)\s*")
FAILWITH_RE = re.compile(r"failwith\s+\"not\s+implemented\"")


def parse(path: Path) -> list[tuple[str, int, list[tuple[int, int]]]]:
    """Return a list of (asked_function, quiz_line, [(line, line)])
    triples, one per `:::quiz code` block. The third element is
    the list of (line, end_line) ranges where the function appears
    to be defined non-stubbily in chapter prose *before* the quiz.
    """

    text = path.read_text()
    lines = text.split("\n")

    in_slide = in_quiz = in_quiz_code = in_solution = False
    in_ocaml = False
    quiz_start_line = -1

    # All chapter-prose ocaml cells, recorded as (line, name, body)
    # for later lookup. Body is the cell text minus the `let NAME`
    # line; we use it to skip stubs.
    chapter_defs: dict[str, list[tuple[int, str]]] = {}
    quiz_blocks: list[tuple[str, int]] = []

    i = 0
    cur_cell_lines: list[str] = []
    cell_start = -1

    while i < len(lines):
        line = lines[i]
        s = line.strip()

        # Block fences. Order matters: closing `:::` may close
        # whichever was open.
        if s.startswith(":::slide"):
            in_slide = True
        elif s.startswith(":::quiz code"):
            in_quiz_code = True
            in_quiz = True
            quiz_start_line = i + 1
        elif s.startswith(":::quiz"):
            in_quiz = True
        elif s.startswith(":::solution"):
            in_solution = True
        elif s == ":::":
            if in_quiz_code:
                # finalize: find first non-failwith `let NAME`
                in_quiz_code = False
            in_slide = in_quiz = in_solution = False

        if s.startswith("```ocaml"):
            in_ocaml = True
            cur_cell_lines = []
            cell_start = i + 1
            i += 1
            continue
        if s == "```":
            if in_ocaml:
                cell_text = "\n".join(cur_cell_lines)
                # Chapter-prose cell: outside slide/quiz/solution
                if not (in_slide or in_quiz or in_solution):
                    for j, l in enumerate(cur_cell_lines):
                        m = LET_RE.match(l)
                        if m:
                            name = m.group(1)
                            if FAILWITH_RE.search(cell_text):
                                # cell with stub: still record but
                                # mark non-stub absent
                                continue
                            chapter_defs.setdefault(name, []).append(
                                (cell_start + j, cell_text[:80])
                            )
                # Quiz starter cell: find the let whose body is
                # `failwith "not implemented"` (the asked function).
                # Scaffold lets defined above are ignored.
                elif in_quiz_code:
                    asked = None
                    for j, l in enumerate(cur_cell_lines):
                        m = LET_RE.match(l)
                        if not m:
                            continue
                        n = m.group(1)
                        if n in HARNESS_NAMES or len(n) == 1:
                            continue
                        # Look ahead for `failwith "not implemented"`
                        # within the next few non-blank lines, before
                        # the next `let` or end of cell.
                        body_lines: list[str] = []
                        for k in range(j + 1, len(cur_cell_lines)):
                            la = cur_cell_lines[k]
                            if LET_RE.match(la):
                                break
                            body_lines.append(la)
                        body = "\n".join(body_lines)
                        if FAILWITH_RE.search(body):
                            asked = n
                            break
                    if asked:
                        quiz_blocks.append((asked, quiz_start_line))
            in_ocaml = False
            i += 1
            continue

        if in_ocaml:
            cur_cell_lines.append(line)
        i += 1

    findings: list[tuple[str, int, list[tuple[int, str]]]] = []
    for asked, quiz_line in quiz_blocks:
        if asked in chapter_defs:
            earlier = [
                (line, snippet)
                for (line, snippet) in chapter_defs[asked]
                if line < quiz_line
            ]
            if earlier:
                findings.append((asked, quiz_line, earlier))

    return findings


def main() -> int:
    violations = 0
    for path in sorted(LECTURES_DIR.glob("M*-L*.md")):
        findings = parse(path)
        if not findings:
            continue
        for asked, quiz_line, earlier in findings:
            if (path.name, asked) in ALLOWLIST:
                continue
            violations += 1
            print(f"{path.name}:{quiz_line}: activity asks for `{asked}`")
            for line, snippet in earlier:
                print(f"  chapter walks `{asked}` through at line {line}")
    if violations:
        print(
            f"\n{violations} activity-fresh-code violation(s). "
            "Pick a fresh function shape or different domain; see "
            "feedback-activity-fresh-code memory."
        )
        return 1
    print("activity-fresh-code: clean")
    return 0


if __name__ == "__main__":
    sys.exit(main())
