#!/usr/bin/env python3
"""Stage selected hunks of one file from a source ref (index and working tree).

The diff is index -> <source-ref> for <path>, so hunks are always relative to
what is already staged and always apply cleanly. Indices are re-counted after
every staging call: list again before selecting more from the same file.

Usage:
  stage-hunks.py <source-ref> <path> --list
  stage-hunks.py <source-ref> <path> --hunks 1,3

Output of --list, one line per hunk:
  <index>  +<added> -<removed>  <hunk header>  |  <first changed line>

Exit codes: 0 ok, 1 usage or git error, 2 no hunks / index out of range.
"""
import argparse
import re
import subprocess
import sys

HUNK_RE = re.compile(r"^@@ -\d+(?:,\d+)? \+\d+(?:,\d+)? @@")


def git(*args, input=None, check=True):
    r = subprocess.run(["git", *args], input=input, text=True,
                       stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if check and r.returncode != 0:
        sys.stderr.write(r.stderr)
        sys.exit(1)
    return r.stdout


def parse(diff_text):
    header, hunks, body = [], [], None
    for line in diff_text.splitlines(keepends=True):
        if HUNK_RE.match(line):
            body = [line]
            hunks.append(body)
        elif body is not None:
            body.append(line)
        else:
            header.append(line)
    return header, hunks


def describe(i, body):
    added = sum(1 for l in body[1:] if l.startswith("+"))
    removed = sum(1 for l in body[1:] if l.startswith("-"))
    first = next((l.rstrip("\n") for l in body[1:] if l[:1] == "+"), None)
    if first is None:
        first = next((l.rstrip("\n") for l in body[1:] if l[:1] == "-"), "")
    head = body[0].rstrip("\n")
    return "{:>3}  +{} -{}  {}  |  {}".format(i, added, removed, head[:60], first[:80])


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("source_ref")
    p.add_argument("path")
    mode = p.add_mutually_exclusive_group(required=True)
    mode.add_argument("--list", action="store_true")
    mode.add_argument("--hunks", help="comma-separated 1-based indices from --list")
    args = p.parse_args()

    diff_text = git("diff", "--cached", "-R", args.source_ref, "--", args.path)
    header, hunks = parse(diff_text)
    if not hunks:
        print("no textual hunks between index and {} for {} "
              "(already staged, or a rename/mode/binary change: use "
              "`git restore --source {} --staged --worktree -- {}`)".format(
                  args.source_ref, args.path, args.source_ref, args.path))
        sys.exit(2)

    if args.list:
        for i, body in enumerate(hunks, 1):
            print(describe(i, body))
        return

    wanted = sorted({int(x) for x in args.hunks.split(",") if x.strip()})
    bad = [i for i in wanted if i < 1 or i > len(hunks)]
    if bad:
        print("hunk index out of range: {} (file has {} hunks; run --list)".format(bad, len(hunks)))
        sys.exit(2)

    patch = "".join(header) + "".join("".join(hunks[i - 1]) for i in wanted)
    git("apply", "--index", "--recount", input=patch)
    print("staged {} hunk(s) of {}; {} remaining".format(len(wanted), args.path, len(hunks) - len(wanted)))


if __name__ == "__main__":
    main()
