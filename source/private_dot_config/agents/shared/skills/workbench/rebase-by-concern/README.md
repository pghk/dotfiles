# rebase-by-concern

Executes an approved concern map as one commit per logical concern.

## Goals

A branch accumulates commits in the order they were written, not the order
that makes it reviewable: a concern gets split across several commits, two
unrelated concerns land in the same commit, and the sequence that made sense
while writing doesn't make sense to a reviewer. `survey-branch` recovers the
concerns and their intent into `.notes/<slug>/map.md`; this skill turns that
map into history, keeping the agent's context cost proportional to the size
of the net change rather than the length of the history.

## Method

The clean history is built **forward**, not rewritten in place. A new
branch starts at `base`; each concern is staged from the original tip
`orig` (`git restore --source <orig>` for whole paths,
`scripts/stage-hunks.py` for part of a file) and committed with the message
from the map. The original branch is never touched.

This makes the state of the work directly observable with one command:
`git diff --stat HEAD <orig>` is what remains, and it shrinks monotonically.
Staging never conflicts, because every hunk is computed against the current
index. Churn inside the original history (a line added, then fixed) collapses
automatically into the concern that owns the final line. Renames, deletions,
mode changes, and binaries need no special handling.

Each commit is verified as it is made, so a hunk staged into the wrong
concern surfaces at that commit. The agent returns to the user only when
execution departs from the map. Placement mistakes are corrected with
ordinary `git rebase -i` on the short clean branch (`--autosquash` to merge,
a reordered todo to insert).

## Known issues

- Reordering on the clean branch can conflict when two placed concerns touch
  the same lines. Resolve as with any rebase; the branch is short and each
  commit is coherent, so this is tractable.
- A concern that must be split out of an already-placed commit requires
  `git rebase -i` with an `edit` stop and manual re-staging. Prefer deciding
  the split in the map; the survey exists to make that the common case.
- Original commit identity is not preserved; the mapping from a final hunk
  to the commit that introduced it is recovered on demand with
  `git log <base>..<orig> -- <path>`, not carried along.
