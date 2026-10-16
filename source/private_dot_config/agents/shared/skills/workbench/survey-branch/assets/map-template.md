---
base: <sha>
orig: <sha>
orig_branch: <name>
clean_branch: <name>
status: mapping
---

# Map: <orig_branch>

## Concerns

Ordered as they will be committed. Each entry's `members` must account for every path in `changes.md`; a path serving two concerns names its hunks.

### 1. <short name>
- kind: layer | feature | fix | fixed (original <sha>, cherry-picked unchanged)
- members: <paths; `path (hunks 1,3)` for a shared file>
- intent: <what this change is for, in the author's terms>
- justification: <why this form and what was rejected, newest first; cite `sessions/<id>.md` entry title>
- homes: <intent item → message | doc <path> | comment <path> | test <path> | skill <name>>
- depends on: <concern numbers>
- needed by: <concern numbers>
- message: |
    <gitmoji> <subject>

    <body>
- open: <questions, each marked with what would settle it; delete when settled>

## Intended differences

Content the clean branch adds, changes, or omits relative to `orig`, each approved. Authored additions (doc paragraph, comment, test, skill edit) that carry an intent item whose home is not the commit message are listed here with the concern they land in.

- <description> — concern <n> — approved <date>

## Unexplained changes

Paths or hunks in `changes.md` with no supporting session evidence. Each resolves to a concern (with intent recovered from the diff and log), a drop with reason, or a follow-up.

- <path or cluster> — <resolution>

## Orphan intent

Deliberation entries in `sessions/` whose settled behavior is absent at `orig`. Each resolves to superseded (by concern n), deliberately abandoned (reason), or a follow-up outside this branch.

- <entry title> `sessions/<id>.md` — <resolution>

## Decisions

Append-only. One line per decision taken with the user.

- <date> <decision>
