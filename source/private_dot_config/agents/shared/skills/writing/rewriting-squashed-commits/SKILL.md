---
name: rewriting-squashed-commits
description: >
  Use when asked to rewrite, reword, or fix up commit messages across a git commit range — especially a range produced by iterative squashing, where each message is a concatenation of earlier commit subjects/bodies separated by blank lines, or where a Jira/ticket key needs to replace a gitmoji prefix ahead of opening a PR.
---

# Rewriting a Squashed Commit Range

**REQUIRED SUB-SKILL:** commit for subject/body rules, wrapping limits, and the gitmoji list. This skill is about _how_ to re-derive an accurate message per commit across a whole range; commit is about what the message should say.

## Overview

A squash workflow that concatenates prior commit messages (separated by blank lines) leaves each surviving commit with a message that reads like several old subjects glued together — often each one gitmoji-prefixed, because that's what a real standalone commit subject looked like before squashing. Near PR time, the gitmoji is replaced by a ticket key (e.g. `RAV-15948`) as the subject prefix for the whole range.

None of that concatenated text is reliable evidence of what the commit _currently_ contains. It may describe an intermediate state from before later commits in the same squash altered it further, or — worse — reference an entirely different, abandoned line of development that this branch's history never actually contained.

## The core rule: rediscover, don't edit

For every commit in the range, read its actual diff (`git show <hash>`) first and compose the new message from that. Do not start from the old message and trim/merge it — editing pulls forward stale claims disguised as prose. Write each message as if seeing the diff for the first time, following every rule in the commit skill (imperative subject, ticket prefix instead of emoji, no diff-as-inventory body, bug fixes lead with the observable failure and its trigger).

## Known failure mode: fabricated provenance

The most damaging error is a plausible-sounding sentence that references a method, variable, or design that never existed in this branch's real history — usually left over from an earlier, since-abandoned attempt at the same change (a different local branch, a `trash/*` ref, a squashed draft). It reads like normal regression narrative ("replaces the old X()/Y() design") and is easy to accept unless checked.

Verify anything a draft message names against the diff, not the old message:

```bash
# Confirm a symbol the draft mentions actually appears in this commit's
# patch (not just in the pre-existing message text):
git show --format='' <hash> | grep -F 'symbolName'

# If a symbol is genuinely absent from the diff, find out whether it
# ever existed anywhere reachable from HEAD, or only on an abandoned line:
git log --oneline --all -S'symbolName' -- <path>
git merge-base --is-ancestor <hash-that-mentions-it> HEAD || echo "not an ancestor — do not cite"
```

A symbol found only on a commit that fails `--is-ancestor` is not part of this branch's history. Drop the reference entirely — do not soften it to "replaces an earlier design" or similar; the earlier design is out of scope, not prior art.

Same scrutiny applies to cited commit hashes used as regression provenance (`1839aa8 introduced...`): confirm with `merge-base --is-ancestor` before citing, per the commit skill's own rule on this.

## Composing each message

- One final message per commit: subject + body reflecting the _current_ diff only. Never itemize every changed method/state as a list — state the organizing principle and the property that follows from it, naming at most one or two symbols as examples (the commit skill's inventory rule).
- Subject: `<TICKET-KEY> <Imperative summary>`, replacing the emoji entirely — same grammar as a gitmoji subject, just a different prefix token. Still capped at 72 chars, ideally ≤50. The ticket key is provided per range — it won't always be `RAV-15948` — so confirm which key applies before starting.
- Emoji sub-lines inside the old message are former standalone commit subjects, only useful as a pointer to _which_ earlier change to go re-derive from the diff — never carry their wording forward verbatim.

## Mechanical workflow

1. Identify the range (`<base>..HEAD`). Record the current tip's raw hash before touching anything — **do not rely on a same-named backup branch**: `git rebase --update-refs` (on by default) drags any branch pointing into the rewritten range forward with the rewrite, silently defeating a backup made moments earlier. Either capture the hash alone (`git rev-parse HEAD`), or run the rebase with `-c rebase.updateRefs=false` (the bundled script does this for you).
2. For each commit, read the diff and draft a new message file. Wrap it with `../commit/wrap-commit-message.py` (handles Unicode-aware line lengths — plain `fmt`/`awk` misjudge width once a message has an em dash or other multibyte character, and `fmt -s` silently inserts double spaces after sentences).
3. Name the drafted files so they sort oldest-commit-first (`01.txt`, `02.txt`, ...) — `git log --reverse --format='%H %s' <range>` gives that order. Run `bulk-reword.sh <base> <messages-dir>` (bundled with this skill) to apply them in one rebase pass instead of responding to N interactive prompts. It refuses to run if the file count doesn't match the commit count.
   - This assumes a straight reword pass with no reordering/dropping. If you need to reorder or drop commits in the same pass, match each message to its commit by the _original_ first-line subject instead of by position — position breaks the moment the todo list order changes.
4. Verify before declaring done:
   - Commit count unchanged: `git log --format='%H' <base>..HEAD | wc -l`
   - Diffstats align 1:1, old to new, in the same order — for each position, compare `git show --stat --format='' <old>` against `git show --stat --format='' <new>`; a set match isn't enough, since a squash can reorder.
   - Tree is byte-identical: `git rev-parse <old-tip>^{tree} <new-tip>^{tree}` — only the messages should have changed.
5. Only after the rebase completes, point a backup branch at the hash you recorded in step 1, if you want one for convenience.

## Common mistakes

| Mistake | Fix |
| --- | --- |
| Editing the old squashed message instead of re-reading the diff | Start from `git show`, not the old text |
| Citing a method/commit without checking it's reachable from HEAD | `git merge-base --is-ancestor` before citing anything |
| Listing every renamed/added method as the body | State the organizing principle + example, not the inventory |
| Trusting a backup branch made before the rebase | Record the raw hash, or use `-c rebase.updateRefs=false` |
| Hand-wrapping with `fmt`/`awk` | Use `wrap-commit-message.py`; byte-based tools miscount em dashes and other multibyte characters |
| Assuming diffstat _sets_ match | Confirm 1:1 order, not just membership — a squash can reorder |
