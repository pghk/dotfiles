# rebase-by-concern

Reorganizes a tangled range of commits into one commit per logical concern.

## Goals

A branch accumulates commits in the order they were written, not the order
that makes it reviewable: a concern gets split across several commits, two
unrelated concerns land in the same commit, and the sequence that made sense
while writing doesn't make sense to a reviewer. This skill produces one
commit per concern through a conversation in which the agent proposes from
evidence and the user decides, while keeping the agent's context cost
proportional to the size of the net change rather than the length of the
history.

## Method

The clean history is built **forward**, not rewritten in place. A new
branch starts at `<base>`; each concern is staged from the original tip
`<orig>` (`git restore --source <orig>` for whole paths,
`scripts/stage-hunks.py` for part of a file) and committed with its final
message. The original branch is never touched.

This makes the state of the work directly observable with one command:
`git diff --stat HEAD <orig>` is what remains, and it shrinks monotonically.
Staging never conflicts, because every hunk is computed against the current
index. Churn inside the original history (a line added, then fixed) collapses
automatically into the concern that owns the final line. Renames, deletions,
mode changes, and binaries need no special handling.

Breadth before depth. The first turn reads only `git log --oneline
--name-only` and `git diff --stat` for the range (a few thousand tokens on a
79-commit, 129-file branch, versus ~55k for the net diff and ~150k for the
per-commit diffs) and proposes a sketch: tentative concerns, rough order,
unresolved clusters. The depth loop then works the sketch one concern at a
time, reading only that concern's paths. Discoveries revise the sketch;
placement mistakes are corrected with ordinary `git rebase -i` on the short
clean branch (`--autosquash` to merge, a reordered todo to insert).

## Known issues

- Reordering on the clean branch can conflict when two placed concerns touch
  the same lines. Resolve as with any rebase; the branch is short and each
  commit is coherent, so this is tractable.
- A concern that must be split out of an already-placed commit requires
  `git rebase -i` with an `edit` stop and manual re-staging. Prefer deciding
  the split before committing; the sketch exists to make that the common case.
- Original commit identity is not preserved; the mapping from a final hunk
  to the commit that introduced it is recovered on demand with
  `git log <base>..<orig> -- <path>`, not carried along.
