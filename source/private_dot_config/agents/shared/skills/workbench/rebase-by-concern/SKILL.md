---
name: rebase-by-concern
description: >
  Reorganize a messy branch into one commit per logical concern, collaboratively, on a new branch. Use to clean up, squash, reorder, or split commits, or make a branch reviewable.
disable-model-invocation: true
---

Build a clean history forward: a new branch from `<base>`, one commit per
concern, each staged from the original tip `<orig>`. The original branch is
never rewritten. The agent maps concerns from evidence; the user decides the
map before anything is committed.

## Setup

`<base>` is the last commit to keep as is; `<orig>` is the original tip.
`git switch -c <clean-branch> <base>`. Every command below reads from
`<orig>`.

## Map the concerns

Keep the map in a file in the session workspace, outside the repository;
in chat, show only what each revision changed. Per concern it records:

- **kind**: *layer* (a foundation or infrastructure spanning features),
  *feature* (one feature end to end, with its demo, tests, and docs), or
  *fix* (an ad-hoc or scope-adjacent change; one concern each)
- **members**: paths, plus `stage-hunks.py --list` hunks for a file shared
  between concerns
- **purpose**: why the concern exists and what it changes for the reader,
  in the terms settled with the user
- **message**: the commit message, drafted from the purpose
- **depends on / needed by**
- **open questions**, including each proposed merge of a fixed entry into
  this concern

The map also lists **intended differences**: anything the clean branch
deliberately adds, changes, or omits relative to `<orig>`, each approved by
the user. An original commit that already is one concern is a fixed entry,
cherry-picked unchanged; merging it into another concern needs the user's
decision, especially when its message states intent ("easy to drop later").

The map is built over rounds of conversation, each more detailed than the
last. The first response reads a horizontal pass and states in plain terms
what the branch appears to aim for and the steps it took toward that goal:
an informal first draft of the concerns and their order. Each later round
refines where the user steers, from concerns to members to shared files.
Write the map file once the overview in chat has settled. Each round also
firms up every concern's purpose until its message can be written from the
conversation. An original message may be reused verbatim when it accurately
and fully describes the concern's purpose; a merged or split concern gets a
message for its settled purpose, never messages joined from several originals.

Each round alternates two modes:

- **Horizontal pass** across the whole range. The first is:

      git log --reverse --oneline --name-only <base>..<orig>
      git diff --stat <base> <orig>

  Later passes trace a new symbol from definition to uses, or read the
  original messages in order to recover the author's narrative.
- **Vertical probe** into one uncertain cluster: `git diff <base> <orig> --
  <paths>`, or `stage-hunks.py <orig> <path> --list` for a shared file;
  `git log <base>..<orig> -- <path>` when intent is unclear from the diff.
  A probe tests the map: a feature that pulls in shared tokens reveals a
  layer; a page exercising several features splits across them.

Probe only clusters whose membership, kind, or dependencies are uncertain.

Default order, which the user may override:

1. Fixes.
2. Infrastructure layers: test, then demo.
3. Foundation layers, each separate from and before its first consumer, so
   the first visible change is its own small commit.
4. Features in dependency order.
5. A page or file serving several features splits across them; each part
   lands with the last dependency it needs.

The map is complete when every path in `git diff --stat <base> <orig>` and
every hunk of a shared file has an owner, and no open question remains.

## Approval gate

Post the complete map, messages included, and ask the user to approve
committing it. Stage and
commit nothing until they do.

## Commit the map

Approval covers every concern, in map order. Per concern:

1. Stage: `git restore --source <orig> --staged --worktree -- <paths>` for
   whole files (handles adds, deletes, renames, modes, binaries; name both
   sides of a rename); `stage-hunks.py <orig> <path> --hunks 1,3` for part
   of a file; `git cherry-pick <sha>` for a fixed entry.
2. Commit with the approved message from the map.
3. Verify: build the affected assets and run the concern's tests.
4. `git diff --stat HEAD <orig>` shows what remains.

Stop and return to the user when execution departs from the map: a hunk no
concern owns, a diff that contradicts its approved message, a member that won't stage cleanly, a failing check, or a
concern that needs splitting. Revise the map together, then resume.

Done when `git diff HEAD <orig>` shows exactly the approved intended
differences.

## Corrections (plain git on the short clean branch)

- Belongs in a placed concern: `git commit --fixup <sha>`, then
  `GIT_SEQUENCE_EDITOR=true git rebase -i --autosquash <base>`.
- Must precede a placed concern: commit it, write the reordered todo to a
  file, then `GIT_SEQUENCE_EDITOR='cp todo.txt' git rebase -i <base>`.

## Context discipline

Never run `git diff <orig>` unqualified or read commits one by one.
Progress is `--stat`; content is per path, for the cluster in play.

## Script

`scripts/stage-hunks.py <orig> <path> --list | --hunks N,M` — hunks of the
index→`<orig>` diff for one file; `--list` prints numbered one-line
summaries, `--hunks` stages the selection into index and working tree.
Indices renumber after each staging; list again before selecting more.
