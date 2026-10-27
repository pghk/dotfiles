---
name: dig
description: >
  Search git history, other branches, the reflog, and past sessions for the origin or evolution of a commit, symbol, or approach: why a change was made, whether a problem was solved elsewhere, or where work was lost.
---

# Dig

Recover the history of a subject by tracing it across git history, other
branches, the reflog, and session records. The subject is a commit, a class
member or symbol, a problem, or an approach. What the current branch shows is
often incomplete: messages are thin after rebases and copies, other branches
hold divergent versions, and work can be lost before it merges.

---

## When to use this

- **Why a change was made.** Rebasing, reordering, and branch copying are
  routine in this workflow, and each hop can erode context:
  - A fix written with a detailed message gets squashed into a feature commit
  - A WIP stash entry holds the original reasoning
  - The real diagnosis was written in a session turn, not in git
  - A commit references an earlier commit by SHA that no longer exists on
    the current branch
- **Whether a problem was solved before.** The solution may live on another
  branch or in an earlier session.
- **How something evolved.** A class member or approach may have diverged
  across branches; the answer is each version and how they relate.
- **Where work went.** Something that should be in the current branch may
  have been lost before it was merged.

With a commit as the subject, work backward from it to the full story. With
any other subject, locate the candidate commits (steps 2–6) and then treat each
as the commit in step 1.

---

## Process

### 1. Read the commit

```bash
git show <sha> --stat --no-patch   # file list
git show <sha>                     # full diff + message
```

Note: keywords in the message, files touched, and any cross-references
(`Follows X`, `See also Y`, `Fixes: ...`).

### 2. Search git history across all branches

```bash
# By keywords from the commit message
git log --all --oneline | grep -i "<keyword>"

# By file(s) touched — follow renames
git log --all --oneline --follow -- <file>

# By similar message patterns
git log --all --oneline --grep="<phrase>"
```

Target: commits that touch the same files, describe the same problem, or
were written close in time on sibling branches.

### 3. Follow explicit chain references

If the message contains "Follows X", "See also X", or "Fixes: X", look up
those SHAs:

```bash
git show <referenced-sha> 2>/dev/null || git log --all --oneline | grep <short-sha>
```

Chain references often lead to the commit that contains the full diagnosis.

### 4. Search the reflog

The reflog records every HEAD movement across rebase steps, cherry-picks,
resets, and amends — including worktrees. Unlike `git log --all` (which
only sees *reachable* commits), the reflog can surface commits from
*deleted* branches, previous amend versions, and cherry-pick origins.

```bash
# Grep reflog entries by keyword — same engine as git log --grep, fast
git log -g --all --oneline --grep="<keyword>"

# Find all cherry-pick and amend operations across all worktrees
git log -g --all --format="%gd %H %gs" | grep "cherry-pick\|amend"

# Trace a specific SHA: when was it introduced, picked, squashed?
git log -g --all --format="%gd %H %gs" | grep "<short-sha>"
```

**What the reflog reveals that branch history doesn't:**
- A commit's previous SHA before amend (`commit (amend):` entry)
- Which branch it lived on before being ported (`cherry-pick:` with origin SHA)
- The rebase sequence: `rebase (start)` → `rebase (pick)` → `rebase (finish)`
- Entries from other worktrees (e.g. `worktrees/main/HEAD@{N}`)

**Limitations:** local only (not shared, not on CI); entries expire after
90 days (normal) or 30 days (unreachable objects).

### 5. Search session history

```bash
# Messages that mention the same keywords, files, or problem
python3 ../workbench/survey-branch/scripts/sessions.py events '<regex>' --agents

# Read around a hit
python3 ../workbench/survey-branch/scripts/sessions.py events . --sessions <id> \
  --since <iso> --until <iso> --agents
```

Search events rather than the session store: the store's turns can stop at
a session's first summary and omit subagent work. Start narrow; widen if
needed. Session messages and approved plans
(`~/.copilot/session-state/<id>/plan.md`) often hold the reasoning that
never made it into a commit message.

### 6. Check stash / WIP entries

```bash
git stash list
git log --all --oneline | grep -i "wip\|stash\|index on\|WIP on"
```

WIP stash entries created by `git stash` carry the original branch and HEAD
message as context.

---

## Synthesis

After gathering sources, produce:

**Problem narrative** — What was actually broken or missing? What were the
symptoms, and what was the root cause?

**The hop chain** — Show the path from original context to current commit.
Example:
```
[Session turn, Jun 12] → 9df11eea (fix: Initialize JWT server key) →
  51ffaa197c (✅ Fix sequential browser test crash) →
    8e1188a (Tighten test infrastructure, as split-out cleanup) →
      a1215db (Remove legacy $CONFIG from HTTP layer, final form)
```

**Improved commit message** — If requested (or if the current message is
clearly insufficient), write a better one using the recovered context.
Follow the `commit` skill's rules (gitmoji + imperative subject +
body with why).

---

## Search strategy for thin messages

| Thin message type | Search strategy |
|---|---|
| One-liner rename or refactor | Search by old name + new name across all branches |
| "Fix tests" | Search by test file path + `--follow` |
| "Cleanup" or "WIP" | Search by files touched + date window |
| No body, feature commit | Search docs files added in same commit; read them first |
| References a ticket (`RAV-XXXXX`) | `git log --all --grep="RAV-XXXXX"` |
| Ported/copied commit (thin message) | `git log -g --all --grep="<keyword>"` to find pre-deletion origin |
| Suspicious amend | `git log -g --all --format="%gd %H %gs" \| grep "amend\|<short-sha>"` |

---

## Output format

Deliver a short prose summary of:

1. **The problem** — what was broken and why it mattered
2. **The chain** — how the fix evolved across hops
3. **The answer** — what `<sha>` specifically does and why it exists here

Then, if a better commit message is warranted, offer one as a code block.
