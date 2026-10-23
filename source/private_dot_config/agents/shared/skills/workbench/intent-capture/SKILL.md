---
name: intent-capture
description: >
  Audit whether a branch's code and docs carry the intent its commit messages record, and draft the missing docs, comments, tests, and skill rules. Use after rebase-by-concern.
disable-model-invocation: true
---

Check, per commit of `<base>..<branch>`, whether a reader of the code would learn the intent the commit message records without reading history, and add what is missing with the user's approval.

## Inputs

`<base>` and `<branch>` (default `HEAD`). The commit messages are the record of intent; when `.notes/<slug>/map.md` exists, its concerns' intent and justification supplement them.

## Audit

Dispatch one sub-agent per batch of about five commits with [references/intent-capture-brief.md](references/intent-capture-brief.md). Batches run in parallel.

## Agree the additions

Post the findings grouped by commit, each partial or absent item with its drafted addition and a recommendation to accept or drop. The user decides; a round covers only undecided items.

## Apply

Per accepted addition: edit the file, `git commit --fixup <sha>` of the commit it belongs to, and verify the affected checks. An addition to a message: write `amend! <old subject>`, a blank line, and the full revised message to a file, then `GIT_EDITOR='cp <file>' git commit --fixup=reword:<sha>`. Then `GIT_SEQUENCE_EDITOR=true git rebase -i --autosquash <base>`.
