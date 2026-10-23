# Intent capture brief

Send this brief to one sub-agent per batch of commits, with the repository root, `<branch>`, the commit shas, and the path of `map.md` when one exists. The agent reads the code at `<branch>` and returns its findings in chat; it edits nothing.

---

You are auditing whether a branch's code captures the intent behind it. Each commit's message records what the change is for and why it takes this form; when `<map.md>` is given, its concern for the commit adds `intent` and `justification`. The code is at `<branch>` in `<repo>`. Your question, per intent item, is whether a reader of the code without the history would learn it, and if not, what should be written where.

Read the commit with `git show --stat --format=%B <sha>`, then its paths at `<branch>`: `git show <branch>:<path>`. For a doc or skill, read the sections the commit touches; for a source file, read the comments and docblocks near the changed symbols; for a test, read the test names and assertions.

Classify each intent item and justification as one of:

- **captured** at `<path>`: quote the sentence, comment, or test name that carries it.
- **partial** at `<path>`: it names the behavior but not the reason, or the reason but in a place a reader of the affected code would not find.
- **absent**.

For each partial or absent item, decide where it belongs and draft the content:

- A **commit message** carries why this change, now, in this form, and what it rejected: knowledge a reader needs only when asking why the history went this way. Report the sentence to add to the message body.
- A **doc** carries a contract or standing constraint a future contributor must follow without reading history (which blocks consume density; why components do not mint their own tokens). Report the file, the section, and the paragraph, written as a description of what is true, never of what changed.
- A **comment** carries a non-obvious local constraint at the line where it bites, where the code would otherwise read as a mistake. Report the file, the anchor line, and the comment text. Omit a comment that would restate the code or justify ordering the code already shows.
- A **test** carries a behavior that must not regress, where the deliberation chose that behavior over an alternative. Report the test file, the test name, and the assertion in one sentence; name an existing test to extend when one covers the same surface.
- A **skill** carries a method lesson: a correction the author made more than once about how the agent should work, or a recurring procedure. Report the skill and the rule in one sentence.

A standing constraint goes to a doc even when the message also carries it; a one-time reason goes to the message only. Report in commit order, one block per commit:

```markdown
### <short sha> <subject>
- <intent item> — captured `<path>`: "<quote>"
- <intent item> — absent → doc `<path>` § <section>: <paragraph>
- <justification> — partial `<path>` (names the rule, not the reason) → comment `<path>:<anchor>`: <text>
```

Draft every addition fully; the main agent will not expand a summary. Do not assess code quality, naming, or structure beyond whether the intent is readable.
