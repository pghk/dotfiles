# Session digest brief

Send this brief to one sub-agent per batch of up to five sessions, with: the session ids, the absolute path of `scripts/sessions.py`, the repository root, `<orig>`, the paths file `.notes/<slug>/paths.txt`, `.notes/<slug>/changes.md`, and the output directory `.notes/<slug>/sessions/`. The agent writes one file per session and returns only the file paths.

---

You are digesting chat sessions that produced part of a branch, to recover what the author intended and why. The final code is at `<orig>` in `<repo>`; the paths that survive there are listed in `<paths-file>`, grouped into clusters in `<changes.md>`. Read `<changes.md>` once first.

For each session id, run:

    python3 <sessions.py> transcript <session-id> --paths <paths-file>

That transcript is everything you may read from the session. It contains every user message, checkpoint summaries, and the assistant's response for turns that first touched a surviving path (named under `touched:`), for the turn before each of those, and for the final turn.

The assistant's statements carry the intent: they name what a change does, why it takes that form, and what it rejected. The user's replies are the verdict on them. Read each shown assistant turn, then the user message that follows it, and record the pair.

Write `<output-dir>/<session-id>.md`:

```markdown
# <session summary> — <session-id>
window: <first turn timestamp> → <last turn timestamp>
clusters: <cluster ids from changes.md this session touched>

## Decisions
- [<turn>] <assistant statement, quoted or closely paraphrased> → [<turn>] <user verdict: "quote" if it corrects or adds, else accepted> — <cluster id or path>

## Reversals
- [<turn>] <X was proposed or built> → [<turn>] <"user quote" or assistant statement that moved to Y, with the reason> — <cluster id>

## Justifications
- [<turn>] <assistant's one-sentence reason the change takes this form> — <cluster id>

## Orphan intent
- [<turn>] <statement> — not present at <orig>: <what you checked>

## Lessons
- [<turn>] <a correction the user made about how the agent should work, or a procedure that recurred>
```

Rules for what qualifies:

- An assistant statement qualifies when it describes a behavior present at `<orig>`. Confirm with one `git grep` or `git show <orig>:<path> | grep` for a symbol or phrase the statement names. If the statement's turn (or the next) touched a surviving path but the behavior is absent, record it under Orphan intent with what you checked. Quote the assistant where its wording is precise; paraphrase only to shorten.
- Quote the user verbatim only where their message adds direction the assistant did not propose, or corrects or rejects a proposal. A reply that agrees is recorded as `accepted`, not quoted.
- A reversal is any place the direction changed: a rejected proposal, an approach abandoned, a value re-tuned. Keep the reason; it is the most valuable line in the file.
- One line per item, prefixed with its turn number so the main agent can reopen the transcript at that turn.
- Lessons are about the agent's method, not the product; they are candidates for a skill, not a commit.

Leave a section empty rather than padding it. Do not summarize the session narrative; do not write commit messages.
