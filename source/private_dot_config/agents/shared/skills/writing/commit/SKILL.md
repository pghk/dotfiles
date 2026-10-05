---
name: commit
description: >
  Style manual for git commit message format — subject line and body conventions. Use when running git commit, composing commit message text including inline in a shell command, rewording, squashing, amending, editing messages during a rebase, or committing on your own initiative mid-task.
---

A commit message answers why this change needs to exist. Keep it terse and exact.

## Rules

**Subject line:**

- `<gitmoji> <imperative summary>`
- Capitalize first word after emoji
- Imperative mood: completes statement "If applied, this commit will [subject]"
- Name the effect on the system, at the coarsest level that stays true — the outcome a reader would notice, not the artifact you opened
- ≤50 chars when possible, hard cap 72
- No trailing period

**Body (if needed):**

- Include when the subject alone doesn't fully convey why
- Skip when the why is self-evident, or the subject covers both what and why
- For a bug fix, lead with the observable failure in its actual operating or test context and the condition that triggers it. Follow with regression provenance when known. Provenance never substitutes for the problem statement; both are facts a reader can't recover from the diff
- State the problem as it presents itself, not as the mechanism producing it — the causal chain is the diff's to show. Pitch it where a ticket would: the failure someone would report, and the condition it happens under. Where a ticket or issue exists, carry only what a reader holding it still lacks
- State the why as the problem that existed, not the chosen solution restated as a need — "we need X so that X" begs the question; name the problem X solves
- Divide the labour: the message establishes the problem, the diff shows the response. Restating the change set — whether as a bulleted inventory or as prose opening "Adds…", "Wraps…", "Asserts instead…" — takes the diff's and the PR's job
- A curated what is not an inventory. The organising principle the change applies, and the property that follows from it, are nowhere in a diff of individual edits — "every GET/POST pair now has its own name matching its controller, so no name reaches another verb's URI by coincidence" earns its place; a list of the renames does not. Where the body states one, put it last, after the problem
- Describe behaviour a reader can observe. Name a symbol when it's the only way to say which thing you mean
- Write about the codebase, not about the work of changing it. The reader arrives later with no memory of the session: what you tried, verified, or ruled out is not their concern
- Reference a prior commit by 7-char short hash, with a parenthetical qualifier where the reference needs a condition attached
- Wrap at 72 chars

**Auto-Clarity**

Always include body for: breaking changes, security fixes, data migrations, anything reverting a prior commit. Never compress these into subject-only — future debuggers need the context. This mandates a body's presence, not its length: a few lines carrying the problem and its trigger meet the bar.

**Publication rewrites**

When preparing an unpublished feature branch for publication:

- Fold corrections to behavior introduced by the feature into the feature commit
- Keep fixes for problems that predate the feature as separate commits
- Drop temporary plans and execution-evidence commits unless they are explicitly part of the deliverable

After squash, fixup, or reorder, reread every surviving message against its final combined diff. Remove rationale about eliminated code, rejected approaches, or development process that the resulting commit does not contain.

**Multi-line commit invocation**

Write multi-line messages with `git commit -F - <<'EOF' ... EOF` (heredoc to stdin). Don't nest a heredoc inside `-m "$(cat <<'EOF' ...)"` — the extra layer of shell quoting breaks.

**Verify the staged state**

Commands such as `git cherry-pick -n`, `git merge --no-commit`, and
`git apply --index` populate the index before later edits. Before committing,
inspect both `git diff --cached` and `git diff`, stage the verified final files,
and confirm the index contains the version that was tested. Do not commit an
earlier staged version while corrected working-tree changes remain unstaged.

**Wrapping a drafted message**

`wrap-commit-message.py` in this skill directory wraps a subject+body to the width and length limits above and flags an over-length subject, without the pitfalls of general-purpose text tools: BSD `fmt -s` silently inserts a double space after every sentence, and `awk 'length'` (and similar byte-counting checks) overcounts a line the moment it has an em dash or other multibyte character, reporting a wrap violation that isn't real. Prefer it over hand-wrapping any time you're composing more than one message, or composing one with non-ASCII punctuation:

```bash
wrap-commit-message.py draft.txt                  # print wrapped, don't touch the file
wrap-commit-message.py --in-place draft.txt        # rewrap in place
printf '%s' "$msg" | wrap-commit-message.py         # via stdin
```

For rewriting an entire commit range at once (not just drafting one message), see the rewriting-squashed-commits skill.

**Resolving a commit to fix up**

`git log --grep=<subject>` also matches the `fixup!`/`squash!` commits created against that subject, so it returns the fixup rather than its target — `rebase --autosquash` then squashes nothing while still reporting success. `--invert-grep` inverts every `--grep` pattern given to it, so it cannot exclude fixups while matching a subject: combining the two selects a commit matching neither, and the fixup silently lands on whatever that is. Resolve the target hash and keep it before creating any fixup.

Nothing fails when a fixup lands on the wrong commit. The rebase reports success, the working tree ends up correct, and the tests still pass — the damage is visible only in the commits. Check each commit's diffstat afterwards to confirm every hunk sits where it belongs.

**Citing a commit**

A rewrite leaves the pre-rewrite copies reachable, and `log -S`/`--grep` still finds them, so a hash lifted from an old message or an earlier search can name a commit that is no longer in the history — including an earlier copy of the commit being written. Confirm every hash you cite with `git merge-base --is-ancestor <hash> HEAD`, and re-resolve it by subject when it fails.

**Rewriting messages in place**

A message routed through an editor — `rebase` reword/squash, or `git commit` with no `-m`/`-F` — is cleaned up with `strip`, which silently deletes every line beginning with `#`. Start no body line with `#` (`#access-form`, `#123`), or reword with `--cleanup=whitespace`. Messages supplied by `-F -` keep such lines.

Drive a scripted reword from the commit's own identity — match the subject in the editor script, or keep an explicit hash-to-message mapping. Todo line numbers silently shift with the range's base and overwrite whichever commit occupies the position. Afterwards, check each rewritten message against that commit's diffstat rather than its subject. (Positional sequencing is safe instead, but only for a straight reword-only pass with no reordering/dropping — see the rewriting-squashed-commits skill.)

`rebase --update-refs` (on by default under `rebase.updateRefs`) moves any branch pointing into the rewritten range, so a branch made just beforehand follows the rewrite instead of preserving it. Record the pre-rewrite SHA to return to.

`rebase --continue` opens an editor after a conflict even when no message is being changed, and blocks until it exits. Set `GIT_EDITOR=true` on any scripted invocation that can reach an editor, and `GIT_SEQUENCE_EDITOR` for `-i`.

---

## Gitmoji — emoji prefix for every commit

Use the **unicode emoji** (not shortcode) at the start of the subject.

### Most Common

| Emoji | Use                           |
| ----- | ----------------------------- |
| ✨    | Add feature                   |
| 🐛    | Fix bug                       |
| 🔒️    | Fix security or privacy issue |
| 🔥    | Remove code or files          |
| ♻️    | Refactor                      |
| 📝    | Documentation                 |
| 💄    | Style                         |
| ⚡️    | Performance                   |
| ✅    | Testing                       |
| ⏪️    | Revert changes                |
| 🔧    | Configuration                 |
| 🚀    | Deploy or release             |

Full list: https://gitmoji.dev
