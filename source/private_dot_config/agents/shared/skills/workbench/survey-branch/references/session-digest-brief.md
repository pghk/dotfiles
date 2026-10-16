# Session digest brief

Send this brief to one sub-agent per batch of sessions totalling up to about 150 KB of transcript (the size column of `sessions.py list`; a large session gets its own agent), with: the session ids, the absolute path of `scripts/sessions.py`, the repository root, `<orig>`, the paths file `.notes/<slug>/paths.txt`, `.notes/<slug>/changes.md`, and the output directory `.notes/<slug>/sessions/`. The agent writes one file per session and returns only the file paths.

---

You are digesting chat sessions that produced part of a branch, to recover what the author intended and why. The final code is at `<orig>` in `<repo>`; the paths that survive there are listed in `<paths-file>`, grouped into clusters in `<changes.md>`. Read `<changes.md>` once first.

For each session id, run:

    python3 <sessions.py> transcript <session-id> --paths <paths-file>

That transcript is everything you may read from the session, plus any artifact under its `## Files` heading (read `.md` and `.tsv` files there; they often hold a decisions trail or handoff). A turn marked `touched:` first edited those surviving paths.

Record intent and justification, not implementation. The assistant's statements carry the reasoning: what a change is for, why it takes this form rather than another, what it rejected and why. The user's replies are the verdict on them. Read each assistant turn with the user message that follows it and record the pair. The test for an item: would a reviewer of the finished commits need it to understand why the code is shaped this way? A selector, property name, or file qualifies only when an alternative to it was weighed; how a thing was wired up, fixed up, or verified does not.

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

- An assistant statement qualifies when the behavior or constraint it argues for is present at `<orig>`. Confirm with one `git grep` or `git show <orig>:<path> | grep` for a symbol or phrase the statement names. If it is absent, record the statement under Orphan intent with what you checked. Quote the assistant where its wording is precise; paraphrase only to shorten. Skip progress reports, verification narration, and tool output summaries.
- Quote the user verbatim only where their message adds direction the assistant did not propose, or corrects or rejects a proposal. A reply that agrees is recorded as `accepted`, not quoted.
- A reversal is any place the direction changed: a rejected proposal, an approach abandoned, a value re-tuned. Keep the reason; it is the most valuable line in the file.
- One line per item, prefixed with its turn number so the main agent can reopen the transcript at that turn.
- Lessons are about the agent's method, not the product; they are candidates for a skill, not a commit.

Leave a section empty rather than padding it. Do not summarize the session narrative; do not write commit messages.
