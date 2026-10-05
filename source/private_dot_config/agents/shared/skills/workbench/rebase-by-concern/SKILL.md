---
name: rebase-by-concern
description: >
  Reorganize a messy branch's commit history into one commit per logical concern, through a collaborative back-and-forth rather than a single-shot rewrite. Use when asked to clean up, squash, reorder, or split commits across a branch or range, or to "make this branch reviewable."
---

Build a clean history forward: a new branch from `<base>`, one commit per
concern, each staged from the original tip `<orig>`. The original branch is
never rewritten. Concerns are identified and ordered in conversation; the
agent proposes from evidence, the user decides.

## Setup

`<base>` is the last commit to keep as is; `<orig>` is the original tip.
`git switch -c <clean-branch> <base>`. Every command below reads from
`<orig>`.

## Breadth pass (first turn)

Read, in one call:

    git log --reverse --oneline --name-only <base>..<orig>
    git diff --stat <base> <orig>

Propose a **sketch**: tentative concerns, rough order, and the clusters you
can't yet separate ("these 40 CSS files: one concern or three?"). The user
reacts; the sketch is a working hypothesis, restated in chat whenever it
changes. Do not read the full net diff or per-commit diffs here.

## Depth loop

Work the sketch roughly in order. Per concern:

1. Read only its paths: `git diff HEAD <orig> -- <paths>`, or
   `scripts/stage-hunks.py <orig> <path> --list` for a file shared by
   several concerns. Consult `git log <base>..<orig> -- <path>` only when
   a change's intent is unclear from the diff.
2. Propose: name, one-line rationale, the paths/hunks it stages, and its
   place relative to committed concerns. Diff on request only.
3. User confirms, narrows, merges, or sets aside.
4. Stage: `git restore --source <orig> --staged --worktree -- <paths>`
   for whole files (handles adds, deletes, renames, modes, binaries; name
   both sides of a rename); `stage-hunks.py <orig> <path> --hunks 1,3` for
   part of a file. Commit with its final message now, while the
   understanding is fresh.
5. `git diff --stat HEAD <orig>` shows what remains. Empty means done.

Tactics for a tangle, pick per cluster: trace a new symbol from definition
to uses; split by component or directory; read the original messages in
order to recover the author's narrative, then regroup.

## Corrections (plain git on the short clean branch)

- Belongs in a placed concern: `git commit --fixup <sha>`, then
  `GIT_SEQUENCE_EDITOR=true git rebase -i --autosquash <base>`.
- Must precede a placed concern: commit it, write the reordered todo to a
  file, then `GIT_SEQUENCE_EDITOR='cp todo.txt' git rebase -i <base>`.
- Stalled on a dependency inside an unresolved cluster: carve the minimal
  prerequisite as its own commit first.

## Context discipline

Never run `git diff <orig>` unqualified or read commits one by one.
Progress is `--stat`; content is per path, for the concern in play. The
remaining diff shrinks with every commit.

## Script

`scripts/stage-hunks.py <orig> <path> --list | --hunks N,M` — hunks of the
index→`<orig>` diff for one file; `--list` prints numbered one-line
summaries, `--hunks` stages the selection into index and working tree.
Indices renumber after each staging; list again before selecting more.
