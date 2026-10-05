#!/usr/bin/env python3
"""GIT_SEQUENCE_EDITOR helper: mark every 'pick' line as 'reword'.

Used by bulk-reword.sh. Not normally invoked directly.
"""
import re
import sys


def main() -> None:
    path = sys.argv[1]
    with open(path, encoding="utf-8") as f:
        lines = f.readlines()

    out = [re.sub(r"^pick ", "reword ", line, count=1) for line in lines]

    with open(path, "w", encoding="utf-8") as f:
        f.writelines(out)


if __name__ == "__main__":
    main()
