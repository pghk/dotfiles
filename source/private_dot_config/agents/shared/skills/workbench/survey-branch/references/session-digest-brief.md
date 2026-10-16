# Session digest brief

Send this brief to one sub-agent per batch of sessions totalling up to about 150 KB of transcript (the size column of `sessions.py list`; a large session gets its own agent), with: the session ids, the absolute path of `scripts/sessions.py`, the repository root, `<orig>`, the paths file `.notes/<slug>/paths.txt`, `.notes/<slug>/changes.md`, and the output directory `.notes/<slug>/sessions/`. The agent writes one file per session and returns only the file paths.

---

You are digesting chat sessions that produced part of a branch, to recover what the author intended and why. The final code is at `<orig>` in `<repo>`; the paths that survive there are listed in `<paths-file>`, grouped into clusters in `<changes.md>`. Read `<changes.md>` once first.

For each session id, run:

    python3 <sessions.py> transcript <session-id> --paths <paths-file>

That transcript is everything you may read from the session, plus any artifact under its `## Files` heading (read `.md` and `.tsv` files there; they often hold a decisions trail or handoff). A turn marked `touched:` first edited those surviving paths.

Recover the deliberation, not a log of what was decided when. The output is read later by someone writing commit messages and documentation who needs to explain why the code is shaped this way; they will not reopen the transcript. The assistant's statements carry most of the reasoning: what a change is for, which alternatives were weighed, what rejected each, what changed its mind. The user's replies are verdicts and corrections. Read each assistant turn with the user message that follows it.

Write `<output-dir>/<session-id>.md`, one entry per question the session worked out, grouped by topic rather than by time:

```markdown
# <session summary> — <session-id>
window: <first turn timestamp> → <last turn timestamp>
clusters: <cluster ids from changes.md this session touched>

## <Question, as a short phrase> — <cluster ids>
Question: <what had to be decided and why it arose>
Considered: <each position, with the reason given for it; include the assistant's own earlier position when it reversed itself>
Settled: <the outcome and the argument that decided it; quote the decisive sentence, whoever said it>
Left open: <consequences deferred, conflicts raised and not resolved; omit if none>
At orig: <present | absent: what you checked>
Turns: <n, m, …>

## Lessons
- <a correction the user made about how the agent should work, or a procedure that recurred> [turns]
```

Rules:

- An entry is complete when its Settled line could be pasted into a commit body or doc paragraph as the explanation. If it only says what was chosen, the reasoning is missing: go back to the turns.
- Every position gets its reason. A rejected alternative with its reason is as valuable as the chosen one; a reversal is two positions in one entry, with what changed the mind between them.
- Quote the user verbatim where they add direction or correct a proposal; record agreement as agreement. Quote the assistant where its wording states a principle precisely.
- `At orig`: confirm the settled behavior with one `git grep` or `git show <orig>:<path> | grep` for a symbol or phrase it names. When absent, the entry stays; the main agent needs to know the discussed design and the final code diverged.
- A selector, property name, or file belongs in an entry only when an alternative to it was weighed. How a thing was wired up, fixed up, or verified is not deliberation; skip progress reports and tool narration.
- Lessons are about the agent's method, not the product; they are candidates for a skill, not a commit.

Do not summarize the session narrative and do not write commit messages; the entries are the material for them.
