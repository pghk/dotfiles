---
name: rebase-by-concern
description: >
  Build a clean branch from an approved concern map: one commit per concern, each staged from the original tip. Use after survey-branch has approved .notes/<slug>/map.md.
disable-model-invocation: true
---

Build a clean history forward: a new branch from `base`, one commit per concern in map order, each staged from the original tip `orig`. The original branch is never rewritten. The map is the authority; this skill executes it and returns to the user when execution departs from it.

## Preconditions

Read `.notes/<slug>/map.md` front matter. Require `status: approved` and `orig` equal to the tip of `orig_branch`; otherwise stop and name [survey-branch](../survey-branch/SKILL.md) as the next step. Then `git switch -c <clean_branch> <base>`, set `status: executing`, and append the start to **Decisions**.

## Commit the map

Per concern, in map order:

1. Stage: `git restore --source <orig> --staged --worktree -- <paths>` for whole files (handles adds, deletes, renames, modes, binaries; name both sides of a rename); `scripts/stage-hunks.py <orig> <path> --hunks 1,3` for part of a file; `git cherry-pick <sha>` for a `fixed` entry. Author an **Intended differences** entry assigned to this concern before committing it.
2. Commit with the message from the map.
3. Verify: build the affected assets and run the concern's tests.
4. `git diff --stat HEAD <orig>` shows what remains.

Stop and return to the user when execution departs from the map: a hunk no concern owns, a diff that contradicts its message, a member that won't stage cleanly, a failing check, or a concern that needs splitting. Revise the map together, append the revision to **Decisions**, then resume.

When `git diff HEAD <orig>` shows exactly the approved intended differences, dispatch one sub-agent with [references/history-review-brief.md](references/history-review-brief.md). Fix each reported item with the corrections below, re-run the review until it reports nothing, then set `status: done`.

## Corrections (plain git on the short clean branch)

- Belongs in a placed concern: `git commit --fixup <sha>`, then `GIT_SEQUENCE_EDITOR=true git rebase -i --autosquash <base>`.
- Must precede a placed concern: commit it, write the reordered todo to a file, then `GIT_SEQUENCE_EDITOR='cp todo.txt' git rebase -i <base>`.

## Context discipline

Never run `git diff <orig>` unqualified or read commits one by one. Progress is `--stat`; content is per path, for the concern in play.

## Script

`scripts/stage-hunks.py <orig> <path> --list | --hunks N,M` — hunks of the index→`<orig>` diff for one file; `--list` prints numbered one-line summaries, `--hunks` stages the selection into index and working tree. Indices renumber after each staging; list again before selecting more.
