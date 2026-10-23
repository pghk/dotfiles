# History review brief

Send this brief to one sub-agent after `hunks.py verify` passes, with `<base>`, `<clean_branch>`, the repository root, and the path of `map.md`. The agent returns the report in chat; it edits nothing.

---

You are reviewing a rebuilt branch against the map it was built from. The branch `<clean_branch>` in `<repo>` holds one commit per kept concern in `<map.md>`, in map order, from `<base>`; its content already matches the map. Your review is of the messages. Read the map completely first.

For each commit, in order, run `git show --stat --format=fuller <sha>` and read the message with the stat. Read a file's diff (`git show <sha> -- <path>`) only when the stat alone cannot settle a check below.

Report under these headings, each item one line naming the commit by subject. Leave a heading empty when nothing qualifies.

**Message against content.** The body explains behavior the diff does not contain, or the subject names a change the stat does not show.

**Reason missing.** The body states what the commit does but not the reason the concern's `justification` gives for it, or states a weaker reason.

Do not review code quality or correctness; the checks did that. Do not propose rewording beyond naming the missing reason.
