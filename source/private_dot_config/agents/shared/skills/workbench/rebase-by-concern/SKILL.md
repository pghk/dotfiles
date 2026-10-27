---
name: rebase-by-concern
description: >
  Build a clean branch from an approved concern map: one commit per concern, each staged from the original tip. Use after survey-branch has approved .notes/<slug>/map.md.
disable-model-invocation: true
---

Build a clean history forward: a new branch from `base`, one commit per concern in map order, each holding exactly the hunks the map assigns it. The original branch is never rewritten. The map is the authority: a departure from it is fixed in the map, and the branch is rebuilt.

## Preconditions

Read `.notes/<slug>/map.md` front matter. Require `status: approved`, `orig` equal to the tip of `orig_branch`, and `python3 scripts/hunks.py check <map>` exiting 0; otherwise stop and name [survey-branch](../survey-branch/SKILL.md) as the next step. A map whose front matter names `stage1_map` was split at a mechanical change that shares lines with later concerns: its `base` is that stage's `orig`, and the stage map must also pass `check`. Then `git switch -c <clean_branch> <base>`, using the stage map's `base` when there is one, set `status: executing`, and append the start to **Decisions**.

## Build

1. `python3 scripts/hunks.py build <map>` commits every concern not marked `split:` in map order, with its message. With a `stage1_map`, build it first, then the map. `<base>` in the steps below is then the stage map's `base`.
2. Verify every commit: `git rebase --exec '<build and test command>' <base>`, using the repository's checks for the affected assets and tests. A failure stops the rebase at the commit that broke.
3. `python3 scripts/hunks.py verify <map>` exits 0: the branch holds exactly the map's kept concerns.

Stop and return to the user when execution departs from the map: a failing check, a commit whose diff contradicts its message, or a concern that needs splitting or reordering. Revise the map together and append the revision to **Decisions**, then rebuild: `git rebase --abort` if one is in progress, `git reset --keep <base>`, and build again.

When `verify` passes, dispatch one sub-agent with [references/history-review-brief.md](references/history-review-brief.md). Fix each reported item in the map and rebuild, re-run the review until it reports nothing, then set `status: done`. The user may separately invoke [intent-review](../intent-review/SKILL.md).

## Context discipline

Never run `git diff <orig>` unqualified or read commits one by one. Progress is `--stat`; content is per path, for the concern in play.
