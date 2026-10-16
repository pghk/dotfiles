# Session digest brief

Send this brief to one sub-agent per batch of up to five sessions, with: the session ids, the absolute path of `scripts/sessions.py`, the repository root, `<orig>`, the paths file `.notes/<slug>/paths.txt`, `.notes/<slug>/changes.md`, and the output directory `.notes/<slug>/sessions/`. The agent writes one file per session and returns only the file paths.

---

You are digesting chat sessions that produced part of a branch, to recover what the author intended and why. The final code is at `<orig>` in `<repo>`; the paths that survive there are listed in `<paths-file>`, grouped into clusters in `<changes.md>`. Read `<changes.md>` once first.

For each session id, run:

    python3 <sessions.py> transcript <session-id> --paths <paths-file>

That transcript is everything you may read from the session. It contains every user message, checkpoint summaries, and the assistant's response only for turns that first touched a surviving path (named under `touched:`) and for the final turn.

Write `<output-dir>/<session-id>.md`:

```markdown
# <session summary> — <session-id>
window: <first turn timestamp> → <last turn timestamp>
clusters: <cluster ids from changes.md this session touched>

## Decisions
- [<turn>] <user quote or assistant statement> — <cluster id or path it concerns>

## Reversals
- [<turn>] tried <X>; moved to <Y> because <reason> — <cluster id>

## Justifications
- [<turn>] <why the change takes this form, in one sentence> — <cluster id>

## Orphan intent
- [<turn>] <statement> — not present at <orig>: <what you checked>

## Lessons
- [<turn>] <a correction the user made about how the agent should work, or a procedure that recurred>
```

Rules for what qualifies:

- Quote the user verbatim wherever they decide, correct, or reject something. A user message counts regardless of whether its turn touched a path.
- An assistant statement counts as a decision or justification only when (a) its turn touched a surviving path and (b) the behavior it describes is present at `<orig>`. Confirm (b) with one `git grep` or `git show <orig>:<path> | grep` for a symbol or phrase the statement names. If (a) holds and (b) fails, record it under Orphan intent with what you checked. Assistant text that passes neither is omitted.
- A reversal is any place the direction changed: a user rejection, an approach abandoned, a value re-tuned. Keep the reason; it is the most valuable line in the file.
- One line per item. Prefix each with its turn number so the main agent can reopen the transcript at that turn.
- Lessons are about the agent's method, not the product; they are candidates for a skill, not a commit.

Leave a section empty rather than padding it. Do not summarize the session narrative; do not write commit messages.
