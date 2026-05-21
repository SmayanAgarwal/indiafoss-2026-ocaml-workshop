#!/usr/bin/env python3
"""
Prepend a standardised opening title slide to every lecture in
lectures/ that does not already have one. Idempotent: re-running
is a no-op once the slide is present.

The slide is a :::slide block wrapping a <div class="title-slide-
inner">, picked up by the .title-slide-inner CSS in
assets/css/slides.css. In chapter mode the slide is hidden via
:has(.title-slide-inner) in assets/css/chapter.css.
"""

import os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LECTURES = os.path.join(ROOT, "lectures")
COURSE = "Functional Programming with OCaml"
INSTRUCTOR_HTML = "KC Sivaramakrishnan<br>IIT Madras"

YAML_RE = re.compile(r"^---\n(.*?)\n---\n", re.DOTALL)
H1_RE = re.compile(r"^# .+$", re.MULTILINE)


def parse_simple_yaml(block: str) -> dict:
    out = {}
    for line in block.splitlines():
        m = re.match(r"^([a-zA-Z_]+):\s*(.*)$", line)
        if not m:
            continue
        k, v = m.group(1), m.group(2).strip()
        if v.startswith('"') and v.endswith('"'):
            v = v[1:-1]
        out[k] = v
    return out


def title_slide_block(title: str, week: str, lecture_no: str) -> str:
    label = ""
    if week and lecture_no:
        label = f"Module {week} &middot; Lecture {lecture_no}"
    label_p = f'<p class="title-slide-label">{label}</p>\n' if label else ""
    return (
        ":::slide\n\n"
        '<div class="title-slide-inner">\n'
        f'<p class="title-slide-course">{COURSE}</p>\n'
        f'<h2 class="title-slide-lecture">{title}</h2>\n'
        f"{label_p}"
        f'<p class="title-slide-instructor">{INSTRUCTOR_HTML}</p>\n'
        "</div>\n\n"
        ":::\n"
    )


def insert_after_h1(content: str, slide: str) -> str | None:
    """Return new content with the slide inserted just after the
    first H1 (and its trailing blank line). Returns None if no H1."""
    h1 = H1_RE.search(content)
    if not h1:
        return None
    # Find the end of the H1 line plus any immediately following blank line.
    line_end = content.find("\n", h1.start())
    if line_end < 0:
        return None
    # Skip a single blank line after the H1 if present, to put the
    # slide one blank line below.
    insert_at = line_end + 1
    if content[insert_at : insert_at + 1] == "\n":
        insert_at += 1
    return content[:insert_at] + "\n" + slide + "\n" + content[insert_at:]


def process(path: str) -> str:
    with open(path) as f:
        content = f.read()
    # Skip if a title slide is already present.
    if "title-slide-inner" in content:
        return "skip"
    m = YAML_RE.match(content)
    if not m:
        return "no-frontmatter"
    fm = parse_simple_yaml(m.group(1))
    title = fm.get("title", "")
    week = fm.get("week", "")
    lecture_no = fm.get("lecture_no", "")
    if not title:
        return "no-title"
    slide = title_slide_block(title, week, lecture_no)
    new = insert_after_h1(content, slide)
    if new is None:
        return "no-h1"
    with open(path, "w") as f:
        f.write(new)
    return "added"


def main():
    counts = {"added": 0, "skip": 0, "no-h1": 0, "no-frontmatter": 0, "no-title": 0}
    for fname in sorted(os.listdir(LECTURES)):
        if not re.match(r"M\d\d-L\d\d-.+\.md$", fname):
            continue
        path = os.path.join(LECTURES, fname)
        result = process(path)
        counts[result] = counts.get(result, 0) + 1
        print(f"{result:>14}  {fname}")
    print()
    for k, v in counts.items():
        if v:
            print(f"{k}: {v}")


if __name__ == "__main__":
    main()
