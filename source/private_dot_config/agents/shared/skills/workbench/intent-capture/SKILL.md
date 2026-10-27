---
name: intent-capture
description: >
  Audit whether a branch's commit messages, code, docs, comments, tests, and skills each carry their share of the intent behind it, and draft what is missing. Use after rebase-by-concern.
disable-model-invocation: true
---

Intent is the purpose and reasoning behind the branch's changes. Each artifact is a projection of it: a commit message carries why this change, now, in this form; a doc carries standing contracts; a comment carries local constraints; a test carries behavior that must hold; a skill carries method lessons. No single projection is authoritative or complete. Check, per commit of `<base>..<branch>`, that every facet of the intent reaches the projection that suits it, and add what is missing with the user's approval. A commit message is audited like the others.

## Inputs

`<base>` and `<branch>` (default `HEAD`). Establish each commit's intent from every source available: the user's statements, `.notes/<slug>/map.md` (a concern's intent and justification), specs and tickets, past sessions (`dig`), and the commit messages. Where sources disagree or leave the intent unclear, ask the user before auditing.

## Audit

Dispatch one sub-agent per batch of about five commits with [references/intent-capture-brief.md](references/intent-capture-brief.md). Batches run in parallel.

## Agree the additions

Post the findings grouped by commit, each partial or absent item with its drafted addition and a recommendation to accept or drop. The user decides; a round covers only undecided items.

## Apply

Per accepted addition: edit the file, `git commit --fixup <sha>` of the commit it belongs to, and verify the affected checks. An addition to a message: write `amend! <old subject>`, a blank line, and the full revised message to a file, then `GIT_EDITOR='cp <file>' git commit --fixup=reword:<sha>`. Then `GIT_SEQUENCE_EDITOR=true git rebase -i --autosquash <base>`.
