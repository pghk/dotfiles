#!/usr/bin/env python3
"""Write a level-two section of the daily note at $NOTES_DIR/Daily/YYYY-MM-DD.md.

The section body is read from stdin. A missing note is created bare. An existing
section is replaced through the next level-one or level-two heading; otherwise
the section is appended. The rest of the note is left unchanged.
"""

import argparse
from datetime import date
import json
import os
from pathlib import Path
import re
import sys

HEADING = re.compile(r" {0,3}(#{1,6})(?:[ \t]+(.*?))?(?:[ \t]+#+)?[ \t]*$")
FENCE = re.compile(r" {0,3}(`{3,}|~{3,})")


def note_path(day):
    root = os.environ.get("NOTES_DIR")
    if not root:
        raise ValueError("NOTES_DIR is not set. Export it as the notes root directory.")
    return Path(root).expanduser() / "Daily" / f"{day.isoformat()}.md"


def headings(lines):
    """Yield (line index, level, title) for headings outside frontmatter and fenced code."""
    start = 0
    if lines and lines[0] == "---":
        start = next((i + 1 for i, line in enumerate(lines[1:], 1) if line in ("---", "...")), 0)
    fence = None
    for index in range(start, len(lines)):
        line = lines[index]
        marker = FENCE.match(line)
        if marker:
            if fence is None:
                fence = marker.group(1)
            elif marker.group(1).startswith(fence):
                fence = None
            continue
        heading = None if fence else HEADING.match(line)
        if heading:
            yield index, len(heading.group(1)), heading.group(2) or ""


def write_section(text, title, body):
    lines = text.splitlines()
    found = list(headings(lines))
    matches = [index for index, level, name in found if level == 2 and name == title]
    if len(matches) > 1:
        raise ValueError(f"The note has {len(matches)} '## {title}' sections; merge them first.")
    section = [f"## {title}", "", *body.strip().splitlines()]
    if not matches:
        while lines and not lines[-1].strip():
            lines.pop()
        return "\n".join(lines + [""] * bool(lines) + section) + "\n"
    start = matches[0]
    end = next((index for index, level, _ in found if index > start and level <= 2), len(lines))
    rest = lines[end:]
    return "\n".join(lines[:start] + section + [""] * bool(rest) + rest) + "\n"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--date", type=date.fromisoformat, default=date.today(), help="YYYY-MM-DD; defaults to today")
    parser.add_argument("--section", required=True, help="Level-two heading title, such as Summary")
    args = parser.parse_args()
    try:
        body = sys.stdin.read()
        if not body.strip():
            raise ValueError("The section body on stdin is empty.")
        if any(level <= 2 for _, level, _ in headings(body.splitlines())):
            raise ValueError("The body must not contain level-one or level-two headings.")
        path = note_path(args.date)
        created = not path.exists()
        original = "" if created else path.read_text(encoding="utf-8")
        updated = write_section(original, args.section, body)
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(updated, encoding="utf-8")
    except (OSError, ValueError) as error:
        print(error, file=sys.stderr)
        return 1
    status = "created" if created else "updated" if updated != original else "unchanged"
    print(json.dumps({"path": str(path), "status": status}))
    return 0


if __name__ == "__main__":
    sys.exit(main())
