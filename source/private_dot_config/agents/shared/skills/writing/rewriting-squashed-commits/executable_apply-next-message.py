#!/usr/bin/env python3
"""GIT_EDITOR helper: apply the next message file in sequence.

Used by bulk-reword.sh, once per 'reword' step, in the order git invokes
them (oldest commit in the range first). Not normally invoked directly.

Reads:
  $BULK_REWORD_MSGDIR   directory of message files, sorted oldest-first
  $BULK_REWORD_COUNTER  scratch file tracking how many reword steps have
                        run so far
"""
import os
import shutil
import sys


def main() -> None:
    msgfile_path = sys.argv[1]
    msgdir = os.environ["BULK_REWORD_MSGDIR"]
    counter_path = os.environ["BULK_REWORD_COUNTER"]

    with open(counter_path, encoding="utf-8") as f:
        raw = f.read().strip()
    n = int(raw or "0") + 1
    with open(counter_path, "w", encoding="utf-8") as f:
        f.write(str(n))

    files = sorted(os.listdir(msgdir))
    if n > len(files):
        sys.exit(
            f"apply-next-message: no message file for reword #{n} in "
            f"{msgdir} (only {len(files)} files) — commit count and file "
            f"count no longer match, likely because the todo list was "
            f"reordered mid-run"
        )

    shutil.copyfile(os.path.join(msgdir, files[n - 1]), msgfile_path)


if __name__ == "__main__":
    main()
