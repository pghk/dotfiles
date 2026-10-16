# History review brief

Send this brief to one sub-agent after the last concern is committed, with `<base>`, `<clean_branch>`, `<orig>`, the repository root, and the path of `map.md`. The agent returns the report in chat; it edits nothing.

---

You are reviewing a rebuilt branch against the map it was built from. The branch `<clean_branch>` in `<repo>` holds one commit per concern listed in `<map.md>`, in map order, from `<base>`. The original tip is `<orig>`. Read the map completely first.

For each commit, in order, run `git show --stat --format=fuller <sha>` and read the message with the stat. Read a file's diff (`git show <sha> -- <path>`) only when the stat alone cannot settle a check below.

Report under these headings, each item one line naming the commit by subject. Leave a heading empty when nothing qualifies.

**Message against content.** The stat includes a path the concern's members do not list, or omits one they do; or the body explains behavior the diff does not contain.

**Reason missing.** The body states what the commit does but not the reason the map's `justification` gives for it, or states a weaker reason.

**Homes not delivered.** An intent item homed in a doc, comment, test, or skill whose named file is not touched by the commit the map assigns it to, or is touched without carrying the intent. Read that file's diff.

**Intended differences.** Each entry under the map's Intended differences, marked delivered or not, with the commit.

**Remainder.** `git diff --stat <clean_branch> <orig>`: every path listed is either an approved intended difference or a defect; name which.

Do not review code quality or correctness; the concern's tests did that. Do not propose rewording beyond naming the missing reason.
