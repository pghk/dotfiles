#!/usr/bin/env python3
"""Wrap a commit message to commit skill conventions.

- Subject line (first line) is left untouched, but its length is
  checked (Unicode codepoints, not bytes — a plain `awk`/`wc -m` count
  can be thrown off by an em dash or other multibyte character).
- Body paragraphs are rewrapped to --width columns (default 72),
  single-spaced. Blank lines between paragraphs are preserved; existing
  line breaks within a paragraph are not.

Usage:
  wrap-commit-message.py [--width N] [--subject-cap N] [--in-place] FILE...
  cat message.txt | wrap-commit-message.py [--width N]

Exits non-zero if any subject exceeds --subject-cap, after still
printing/writing every message.
"""
from __future__ import annotations

import argparse
import sys
import textwrap


def wrap_message(text: str, width: int) -> tuple[str, int]:
    lines = text.split("\n")
    subject = lines[0].rstrip() if lines else ""
    subject_len = len(subject)

    rest = lines[1:]
    if rest and rest[0].strip() == "":
        rest = rest[1:]

    paragraphs: list[str] = []
    current: list[str] = []
    for line in rest:
        if line.strip() == "":
            if current:
                paragraphs.append(" ".join(current))
                current = []
        else:
            current.append(line.strip())
    if current:
        paragraphs.append(" ".join(current))

    wrapped_paragraphs = [
        "\n".join(
            textwrap.wrap(
                paragraph,
                width=width,
                break_long_words=False,
                break_on_hyphens=False,
            )
        )
        for paragraph in paragraphs
    ]

    body = "\n\n".join(wrapped_paragraphs)
    result = subject + ("\n\n" + body if body else "\n")
    return result, subject_len


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("files", nargs="*")
    parser.add_argument("--width", type=int, default=72)
    parser.add_argument("--subject-cap", type=int, default=72)
    parser.add_argument("--in-place", action="store_true")
    args = parser.parse_args()

    sources = args.files or ["-"]
    exit_code = 0

    for src in sources:
        if src == "-":
            text = sys.stdin.read()
        else:
            with open(src, encoding="utf-8") as f:
                text = f.read()

        wrapped, subject_len = wrap_message(text, args.width)

        if subject_len > args.subject_cap:
            print(
                f"warning: {src}: subject is {subject_len} chars "
                f"(cap {args.subject_cap})",
                file=sys.stderr,
            )
            exit_code = 1

        if not wrapped.endswith("\n"):
            wrapped += "\n"

        if args.in_place and src != "-":
            with open(src, "w", encoding="utf-8") as f:
                f.write(wrapped)
        else:
            sys.stdout.write(wrapped)

    sys.exit(exit_code)


if __name__ == "__main__":
    main()
