#!/bin/bash
# Reword every commit in <base>..HEAD using pre-written message files.
#
# Usage:
#   bulk-reword.sh <base-commit> <messages-dir>
#
# <messages-dir> must contain exactly one message file per commit in the
# range, named so that a plain `ls` sorts them oldest-commit-first (e.g.
# 01.txt, 02.txt, ...). `git log --reverse --format='%H %s' <base>..HEAD`
# gives that order. Each file's first line is the subject; the rest is
# the body (run them through wrap-commit-message.py first — see the
# commit skill).
#
# Runs the rebase with rebase.updateRefs disabled, so any other branch
# pointing into the rewritten range is left where it was rather than
# dragged forward — see the rewriting-squashed-commits skill for why
# that matters for a backup branch made just before this runs.
#
# Assumes a straight reword pass: no reordering, dropping, or squashing
# in the same run. If you need those, apply messages by matching each
# commit's original subject instead of by position.

set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "usage: bulk-reword.sh <base-commit> <messages-dir>" >&2
  exit 1
fi

base="$1"
msgdir="$2"
skill_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -d "$msgdir" ]; then
  echo "bulk-reword: $msgdir is not a directory" >&2
  exit 1
fi

n_commits="$(git rev-list --count "$base"..HEAD)"
n_files="$(find "$msgdir" -maxdepth 1 -type f | wc -l | tr -d ' ')"
if [ "$n_commits" != "$n_files" ]; then
  echo "bulk-reword: $n_commits commits in range but $n_files files in $msgdir — aborting" >&2
  exit 1
fi

export BULK_REWORD_MSGDIR="$msgdir"
BULK_REWORD_COUNTER="$(mktemp)"
export BULK_REWORD_COUNTER
echo 0 > "$BULK_REWORD_COUNTER"

GIT_SEQUENCE_EDITOR="python3 $skill_dir/mark-all-reword.py" \
GIT_EDITOR="python3 $skill_dir/apply-next-message.py" \
  git -c rebase.updateRefs=false rebase -i "$base"

rm -f "$BULK_REWORD_COUNTER"
