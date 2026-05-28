#!/usr/bin/env python3
"""Sync the per-module tables in RECORDING-ESTIMATES.md so the
MCQ and Code columns reflect the current lecture state.

Idempotent. Handles both shapes of data row:

  old  | M07-L03 | Topic | Slides | Video | Recording |
  new  | M07-L03 | Topic | Slides | MCQ | Code | Video | Recording |

In both cases we strip down to (name, topic, slides, video,
recording), recompute (mcq, code) from `:::quiz mcq` /
`:::quiz code` counts in lectures/, and write back in the new
7-column form. Re-running on the new form is a no-op modulo
freshened mcq/code counts.

Header / separator / total / hours rows are rewritten too.
"""

from __future__ import annotations

import re
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parent.parent
LECTURES = REPO_ROOT / "lectures"
REPORT = REPO_ROOT / "RECORDING-ESTIMATES.md"


def quiz_counts(name: str) -> tuple[int | None, int | None]:
    candidates = list(LECTURES.glob(f"{name}-*.md"))
    if not candidates:
        return (None, None)
    text = candidates[0].read_text()
    mcq = len(re.findall(r"^:::quiz mcq", text, re.MULTILINE))
    code = len(re.findall(r"^:::quiz code", text, re.MULTILINE))
    return (mcq, code)


HEADER_NEW = "| Lecture | Topic | Slides | MCQ | Code | Video (min) | Recording (min) |"
HEADER_OLD = "| Lecture | Topic | Slides | Video (min) | Recording (min) |"
SEP_NEW = "|---|---|---:|---:|---:|---:|---:|"
SEP_OLD = "|---|---|---:|---:|---:|"

# Row matcher: split on ` | ` and recognise by cell count rather
# than a brittle regex with greedy .* . Returns (name, topic,
# slides, mcq_or_none, code_or_none, video, recording).
NAME_RE = re.compile(r"^M\d+-L\d+$")


def parse_row(line: str) -> tuple[str, str, str, str | None, str | None, str, str] | None:
    if not line.startswith("| ") or not line.endswith(" |"):
        return None
    cells = [c.strip() for c in line[2:-2].split(" | ")]
    if len(cells) < 5:
        return None
    if not NAME_RE.match(cells[0]):
        return None
    if len(cells) == 5:
        # old form: name | topic | slides | video | recording
        return (cells[0], cells[1], cells[2], None, None, cells[3], cells[4])
    if len(cells) == 7:
        # new form: name | topic | slides | mcq | code | video | recording
        return (cells[0], cells[1], cells[2], cells[3], cells[4], cells[5], cells[6])
    return None


TOTAL_RE = re.compile(
    r"^\| \*\*(M\d+) total\*\* \| \|\s+(.*?)\s*\|\s*$"
)
TOTAL_PARTS_RE = re.compile(r"\*\*([\d?]+)\*\*")


def parse_total(line: str):
    m = TOTAL_RE.match(line)
    if not m:
        return None
    mod = m.group(1)
    parts = TOTAL_PARTS_RE.findall(m.group(2))
    # We expect either 3 (slides, video, recording) or
    # 5 (slides, mcq, code, video, recording) bold numbers.
    if len(parts) == 3:
        slides, video, recording = parts
        return (mod, slides, video, recording)
    if len(parts) == 5:
        slides, _, _, video, recording = parts
        return (mod, slides, video, recording)
    return None


HOURS_RE = re.compile(
    r"^\|\s+(\|\s+)*(\*\*\([^|*]+\)\*\*) \| (\*\*\([^|*]+\)\*\*)\s*\|\s*$"
)


def is_hours_row(line: str) -> tuple[str, str] | None:
    # Hours rows look like "| | | | **(2.6 h)** | **(3.6 h)** |"
    # (old) or with two more leading "| |" in the new form.
    if "h)**" not in line:
        return None
    parts = re.findall(r"\*\*\(([^*]+) h\)\*\*", line)
    if len(parts) != 2:
        return None
    return (parts[0], parts[1])


def main() -> None:
    src = REPORT.read_text()
    lines = src.split("\n")
    out: list[str] = []
    mod_totals: dict[str, tuple[int, int]] = {}

    for line in lines:
        stripped = line.strip()
        if stripped == HEADER_OLD or stripped == HEADER_NEW:
            out.append(HEADER_NEW)
            continue
        if stripped == SEP_OLD or stripped == SEP_NEW:
            out.append(SEP_NEW)
            continue
        row = parse_row(line)
        if row is not None:
            name, topic, slides, _, _, video, recording = row
            mcq, code = quiz_counts(name)
            mcq_s = str(mcq) if mcq is not None else "?"
            code_s = str(code) if code is not None else "?"
            mod = name.split("-")[0]
            cm, cc = mod_totals.get(mod, (0, 0))
            mod_totals[mod] = (cm + (mcq or 0), cc + (code or 0))
            out.append(
                f"| {name} | {topic} | {slides} | {mcq_s} | {code_s} | {video} | {recording} |"
            )
            continue
        tot = parse_total(line)
        if tot is not None:
            mod, slides, video, recording = tot
            cm, cc = mod_totals.get(mod, (0, 0))
            out.append(
                f"| **{mod} total** | | **{slides}** | **{cm}** | **{cc}** | **{video}** | **{recording}** |"
            )
            continue
        hrs = is_hours_row(line)
        if hrs is not None:
            v_h, r_h = hrs
            out.append(f"| | | | | | **({v_h} h)** | **({r_h} h)** |")
            continue
        out.append(line)

    REPORT.write_text("\n".join(out))
    print(f"rewrote {REPORT.relative_to(REPO_ROOT)}")


if __name__ == "__main__":
    main()
