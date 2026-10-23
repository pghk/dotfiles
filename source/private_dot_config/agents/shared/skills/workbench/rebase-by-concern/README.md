# rebase-by-concern

Executes an approved concern map as one commit per logical concern.

## Goals

A branch accumulates commits in the order they were written, not the order
that makes it reviewable: a concern gets split across several commits, two
unrelated concerns land in the same commit, and the sequence that made sense
while writing doesn't make sense to a reviewer. `survey-branch` settles the
concerns with the user and assigns every hunk of the net diff to one of them
in `.notes/<slug>/map.md`; this skill turns that map into history, keeping
the agent's context cost proportional to the size of the net change rather
than the length of the history.

## Method

The clean history is built **forward**, not rewritten in place. A new
branch starts at `base`; `scripts/hunks.py build` commits each concern with
the message from the map. Each commit's tree is computed, not patched: every
changed path is set to `base` plus the hunks of the concerns committed so
far, where the hunks are those of `git diff --no-renames base orig`. Hunks of
one diff never overlap, so any subset applies cleanly in any order, and hunk
ids stay stable however the concerns are ordered. Churn inside the original
history collapses into the concern that owns the final line. Renames are a
deletion and an addition; binary, mode-only, added, and deleted files move
as whole files.

Because the build is a function of the map, the map stays the authority.
`hunks.py verify` confirms the branch holds exactly the map's kept concerns.
A placement mistake found while verifying the commits is corrected in the
map and the branch is rebuilt from `base`, so there is no conflict
resolution and no hand-edited history.

## Tests

`python3 -m unittest discover -s tests` from this directory.

## Known issues

- A hunk is the unit of assignment. Two changes separated by six or fewer
  unchanged lines share a hunk and cannot go to different concerns.
- Original commit identity is not preserved; the mapping from a final hunk
  to the commit that introduced it is recovered on demand with
  `git log <base>..<orig> -- <path>`, not carried along.
