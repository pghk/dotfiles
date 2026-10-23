---
base: <sha>
orig: <sha>
orig_branch: <name>
clean_branch: <name>
status: primary
---

# Map: <orig_branch>

## Primary concern

- statement: <one sentence: what this branch is for>
- intent: <what the change achieves, in the user's terms>
- justification: <why this form and what was rejected; cite commits, session turns, or `sessions/<id>.md` entries>
- boundary: <what belongs to it, and what does not>

## Concerns

Ordered as they will be committed: misc, dependency, primary, supporting. `members` lists paths, or `path#n,m` hunks for a path serving more than one concern; `hunks.py` reads `members`, `disposition`, and `message`.

### 1. <short name>
- tier: misc | dependency | primary | supporting
- disposition: keep | split:<branch>
- intent: <what this change is for>
- justification: <why this form and what was rejected, with citations>
- depends on: <concern numbers>
- members:
    - <path>
    - <path#2,3>
- message: |
    <gitmoji> <subject>

    <body>
- open: <question, with what would settle it; delete when settled>

## Dropped

Hunks of `<base>..<orig>` left out of the clean branch.

- <path or path#n> — <reason>

## Decisions

Append-only. One line per decision taken with the user.

- <date> <decision>
