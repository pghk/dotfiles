---
name: survey-branch
description: >
  Recover what a WIP branch's changes are for from its net diff and the chat sessions that produced them, and settle an approved concern map in .notes/ that rebase-by-concern executes.
disable-model-invocation: true
---

Produce `.notes/<slug>/map.md`: the branch's concerns, each with its intent, justification, where that intent should live, and its commit message, approved by the user. Sub-agents read the evidence; the main agent reads only their outputs and cross-references them with the user. Nothing in git changes.

## Setup

`<base>` is the last commit to keep; `<orig>` is the tip of the original branch; `<slug>` is the branch name with `/` replaced by `-`. Notes live in `.notes/<slug>/` inside the worktree; on first run add `.notes/` to `$(git rev-parse --git-path info/exclude)`.

If `map.md` exists, read its front matter and resume at its `status`. Without it, a step whose output file already exists is done: `changes.md` for step 1, `sessions/<id>.md` per session for step 2. If `orig` there is behind the branch tip, survey only the new range (steps 1–2 with `<old orig>..<new orig>`, digesting only sessions whose last turn is after the previous survey), merge the results into the existing files, and update `orig`.

## 1. Change survey

Write `.notes/<slug>/paths.txt` from `git diff --name-only <base> <orig>`. Dispatch one sub-agent with [references/change-survey-brief.md](references/change-survey-brief.md). Done when `changes.md` exists and every path in `paths.txt` appears in a cluster.

## 2. Session survey

List candidates:

    python3 scripts/sessions.py list <orig_branch> <first commit author date> --cwd <worktree>

Work carried over from an earlier branch was deliberated in that branch's sessions: when `changes.md` or the log shows ported commits, run `list` again for each such branch with its own start date and add those sessions to the candidates.

Dispatch one sub-agent per batch of sessions totalling about 150 KB of transcript (size column of `list`; a large session alone) with [references/session-digest-brief.md](references/session-digest-brief.md); batches run in parallel. Done when `sessions/<id>.md` exists for every candidate. Record `status: mapping`.

## 3. Draft the map in one pass

Copy [assets/map-template.md](assets/map-template.md) to `map.md` and fill it completely from `changes.md` and `sessions/*.md`, without asking questions first. Per cluster: gather its deliberation entries across sessions, newest first; the latest entry present at `orig` governs the intent, earlier ones supply justification and rejected alternatives. Clusters with no session evidence go to **Unexplained changes**; entries marked absent at `orig` go to **Orphan intent**. An original commit that already is one concern is a `fixed` entry.

Choose each intent item's home:

- **message**: why this change, now, in this form; knowledge only history needs
- **doc**: a contract or behavior a reader must know without history
- **comment**: a non-obvious local constraint, at the line where it bites
- **test**: behavior that must not regress
- **skill**: a procedure the agent repeated or a correction the user made more than once (from the digests' Lessons)

A home other than message becomes an entry under **Intended differences**.

Order: fixes; infrastructure layers; foundation layers, each before its first consumer; features in dependency order. Draft every message. Mark each uncertainty as an `open:` line at the entry it affects, stating what would settle it. Reuse an original message verbatim only when it fully states the settled intent.

## 4. Close open questions

Post the draft's open questions in chat, grouped by concern, each with the recommended answer. The user answers in chat or edits `map.md` directly; re-read the file before each round. A round covers only open items. Probe the repository only to settle a specific open question: `git diff <base> <orig> -- <path>`, `git log <base>..<orig> -- <path>`, or the session transcript, searched for a phrase from the entry. Append each settled item to **Decisions**.

## 5. Approval

When no `open:` lines remain and every residue item is resolved, post the complete map and ask once for approval. On approval set `status: approved`, append the decision, and return. Execution is [rebase-by-concern](../rebase-by-concern/SKILL.md).

## Context discipline

Never read a session transcript whole, a per-commit diff, or an unqualified `git diff <base> <orig>`. Evidence enters through `changes.md` and `sessions/*.md`; the map cites them by cluster id and entry title.
