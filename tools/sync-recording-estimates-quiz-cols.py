#!/usr/bin/env python3
"""Sync the per-module tables in RECORDING-ESTIMATES.md so that the
MCQ and Code columns reflect the *current* lecture state.

Rewrites every per-module table row in place from the live quiz
counts in lectures/*. Idempotent: header rows already in MCQ/Code
shape are detected and the data rows are recomputed unconditionally.

Run this any time you add, remove, or restructure a lecture's
:::quiz mcq / :::quiz code blocks.
"""

from __future__ import annotations

import re
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parent.parent
LECTURES = REPO_ROOT / "lectures"
REPORT = REPO_ROOT / "RECORDING-ESTIMATES.md"


def quiz_counts(name: str) -> tuple[int | None, int | None]:
    """For "M07-L03", return (mcq, code). (None, None) if absent."""
    candidates = list(LECTURES.glob(f"{name}-*.md"))
    if not candidates:
        return (None, None)
    text = candidates[0].read_text()
    mcq = len(re.findall(r"^:::quiz mcq", text, re.MULTILINE))
    code = len(re.findall(r"^:::quiz code", text, re.MULTILINE))
    return (mcq, code)


HEADER_OLD = "| Lecture | Topic | Slides | Video (min) | Recording (min) |"
HEADER_NEW = "| Lecture | Topic | Slides | MCQ | Code | Video (min) | Recording (min) |"
SEP_OLD = "|---|---|---:|---:|---:|"
SEP_NEW = "|---|---|---:|---:|---:|---:|---:|"

ROW_OLD = re.compile(
    r"^\| (M\d+-L\d+) \| (.*) \| (\d+) \| (\d+) \| (\d+) \|\s*$"
)
ROW_NEW = re.compile(
    r"^\| (M\d+-L\d+) \| (.*) \| (\d+) \| ([\d?]+) \| ([\d?]+) \| (\d+) \| (\d+) \|\s*$"
)
TOT_OLD = re.compile(
    r"^\| \*\*(M\d+) total\*\* \| \| \*\*(\d+)\*\* \| \*\*(\d+)\*\* \| \*\*(\d+)\*\* \|\s*$"
)
TOT_NEW = re.compile(
    r"^\| \*\*(M\d+) total\*\* \| \| \*\*(\d+)\*\* \| \*\*[\d?]+\*\* \| \*\*[\d?]+\*\* \| \*\*(\d+)\*\* \| \*\*(\d+)\*\* \|\s*$"
)
HOURS_OLD = re.compile(r"^\| \| \| \| (\*\*\([^|]+\)\*\*) \| (\*\*\([^|]+\)\*\*) \|\s*$")
HOURS_NEW = re.compile(r"^\| \| \| \| \| \| (\*\*\([^|]+\)\*\*) \| (\*\*\([^|]+\)\*\*) \|\s*$")


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
        m = ROW_OLD.match(line) or ROW_NEW.match(line)
        if m:
            if len(m.groups()) == 5:
                name, topic, slides, video, recording = m.groups()
            else:
                name, topic, slides, _, _, video, recording = m.groups()
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
        m = TOT_OLD.match(line) or TOT_NEW.match(line)
        if m:
            if len(m.groups()) == 4:
                mod, slides, video, recording = m.groups()
            else:
                mod, slides, video, recording = m.groups()
            cm, cc = mod_totals.get(mod, (0, 0))
            out.append(
                f"| **{mod} total** | | **{slides}** | **{cm}** | **{cc}** | **{video}** | **{recording}** |"
            )
            continue
        m = HOURS_OLD.match(line) or HOURS_NEW.match(line)
        if m:
            v_h, r_h = m.groups()
            out.append(f"| | | | | | {v_h} | {r_h} |")
            continue
        out.append(line)

    REPORT.write_text("\n".join(out))
    print(f"rewrote {REPORT.relative_to(REPO_ROOT)}")


if __name__ == "__main__":
    main()
