#!/usr/bin/env bash
# git-diff-grep — search for a pattern inside the diff of a commit or range
# Usage:
#   git diff-grep "PATTERN" <commit> [<commit>]
# Examples:
#   git diff-grep TODO HEAD
#   git diff-grep "printf" HEAD~5 HEAD

set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Usage: git diff-grep <PATTERN> <commit> [<commit>]" >&2
  exit 1
fi

pattern="$1"
shift

# Determine if one or two commits were passed
if [ $# -eq 1 ]; then
  range="$1"
  git show "$range" --unified=0
else
  range="$1..$2"
  git diff "$range" --unified=0
fi |

# AWK section — parses the diff and finds matching lines.
awk -v pat="$pattern" '
  # When we see "diff --git a/... b/..." — store the filename ("b/...").
  /^diff --git/ {
    file = $4
    sub(/^b\//, "", file)     # Strip the b/ prefix
    next
  }

  # When we see "@@ -a,b +c,d @@" — extract the old and new starting line numbers.
  /^@@/ {
    # Example: "@@ -12,7 +42,9 @@"
    old = new = 0

    # Parse old starting line number (after the first "-")
    dash_pos = index($0, "-")
    if (dash_pos > 0) {
      tmp = substr($0, dash_pos + 1)
      old = int(tmp)
    }

    # Parse new starting line number (after the first "+")
    plus_pos = index($0, "+")
    if (plus_pos > 0) {
      tmp = substr($0, plus_pos + 1)
      new = int(tmp)
    }
    next
  }

  # For added lines (start with "+", but not "+++" which is a file header)
  /^\+/ && !/^\+\+\+/ {
    if ($0 ~ pat)
      print file ":" new ":" $0
    new++    # Advance new-file line counter
    next
  }

  # For removed lines (start with "-", but not "---" header)
  /^-/ && !/^---/ {
    if ($0 ~ pat)
      print file ":" old ":" $0
    old++    # Advance old-file line counter
    next
  }

  # For context lines (start with space)
  /^ / {
    old++
    new++
  }
'