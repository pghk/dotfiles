---
name: survey-branch
description: >
  Settle with the user what a WIP branch is for, its primary concern and the concerns around it, and assign every hunk of its net diff to them in an approved .notes/ map that rebase-by-concern executes.
disable-model-invocation: true
---

Produce `.notes/<slug>/map.md`, approved by the user: the branch's primary concern, the concerns ordered around it, and an owner for every hunk of the net diff. The primary concern comes first because every other concern is defined against it. The user is the authority on intent; the evidence tools below inform the conversation and answer questions of fact. Nothing in git changes.

## Setup

`<base>` is the last commit to keep; `<orig>` is the tip of the original branch; `<slug>` is the branch name with `/` replaced by `-`. Notes live in `.notes/<slug>/` inside the worktree; on first run add `.notes/` to `$(git rev-parse --git-path info/exclude)` and copy [assets/map-template.md](assets/map-template.md) to `map.md`. If `map.md` exists, read it and resume at its `status`. If the branch tip has moved past `orig`, update `orig`, run `hunks.py check`, and assign what it reports; reassign the hunks of any split path the new commits touched, since its hunk numbers may have shifted.

`hunks.py` is [../rebase-by-concern/scripts/hunks.py](../rebase-by-concern/scripts/hunks.py); run it with `--help` for the id and map formats.

## Evidence tools

Take the cheapest tool that answers the question in hand. Each later tool costs more context or a sub-agent.

1. Commit subjects: `git log --format='%h %s' <base>..<orig>`. A body, `git log -1 --format=%b <sha>`, when its subject suggests the reasoning is there.
2. Shape of the change: `git diff --stat <base> <orig>`, or `--dirstat=files` when the stat exceeds about 100 paths; `hunks.py list <base> <orig>` for status and hunk count per path, `--hunks <path>` for one file's hunks.
3. One path's diff: `git diff <base> <orig> -- <path>`.
4. Sessions: `python3 scripts/sessions.py list <orig_branch> <first commit author date> --cwd <worktree>` for candidates and their summaries; `sessions.py search '<terms>' --sessions <ids>` to find where a question was discussed; `sessions.py transcript <id> --turns A-B` to read around a hit. Work ported from an earlier branch was deliberated in that branch's sessions; when the log shows ported commits, list that branch's sessions too.
5. Session digest: when a concern's reasoning is spread across whole sessions, write `git diff --name-only <base> <orig>` to `.notes/<slug>/paths.txt` and dispatch one sub-agent per batch of about 150 KB of transcript (size column of `list`) with [references/session-digest-brief.md](references/session-digest-brief.md). Digests persist in `sessions/<id>.md`.
6. Change survey: when the branch is too large to orient from tools 1–2, dispatch one sub-agent with [references/change-survey-brief.md](references/change-survey-brief.md). It writes `changes.md`.

Never read a session transcript whole, a per-commit diff, or an unqualified `git diff <base> <orig>`.

## Conversation

Steps 1 and 2 run in frontier rounds, as in [brainstorming](../../brainstorming/SKILL.md): each round asks every open question that is ready to answer, in one numbered message, each with context and a recommended answer. Settle questions of fact with the evidence tools instead of asking. Record each answer in `map.md` and append it to **Decisions**; the user may edit `map.md` directly, so re-read it before each round.

## 1. Primary concern

Orient with tools 1, 2, and the summaries from `sessions.py list`. Post a guess at the **Primary concern** section (statement, intent, justification, boundary) with the evidence behind each part, then refine it with the user. Done when the user accepts the section; set `status: concerns`.

## 2. Concerns around it

Propose the remaining concerns, each defined against the primary's boundary, in commit order by tier:

- **misc**: organisational changes the user puts first in a branch, though nothing depends on them;
- **supporting**: changes made alongside the primary that improve what it builds on, though it does not require them, each before what it supports;
- **dependency**: changes the primary concern needs, each before its first consumer;
- **primary**.

One concern is one commit. Fill every field of the template entry. Draft a concern's message once the user accepts its intent; until then post the intent as a question. `disposition: split:<branch>` marks a concern that belongs on another branch. Done when the user accepts the list; set `status: assigning`.

## 3. Assign hunks

When an early concern is mechanical (a rename, move, or reformat) and later concerns rewrite the same lines, no hunk split gives its commit a tree that builds. Build it first as a stage: replay its commits onto `base` in a scratch index (`git apply --3way`), pin the result as `refs/survey/<slug>/stage1`, and give its concerns a `map-stage1.md` whose `orig` is that commit. Then set `map.md`'s `base` to it and `stage1_map: map-stage1.md`, and assign the remaining hunks against it.

Give every path from `hunks.py list` to one concern's `members` or to **Dropped** with a reason. Name hunks (`path#2,3`) only for a path that serves more than one concern. When owners are not evident from the concerns and the stat, dispatch one sub-agent with [references/hunk-assignment-brief.md](references/hunk-assignment-brief.md). Post each uncertain owner with a recommendation. A hunk that fits no concern reopens step 2. Done when `hunks.py check map.md` exits 0; set `status: review`.

## 4. Review

Dispatch one sub-agent with [references/map-review-brief.md](references/map-review-brief.md). Take each reported item to the user as a question or fix it in the map, then re-run the review. Done when it reports nothing.

## 5. Approval

Post the complete map and ask once for approval. On approval set `status: approved`, append the decision, and return. Execution is [rebase-by-concern](../rebase-by-concern/SKILL.md).
