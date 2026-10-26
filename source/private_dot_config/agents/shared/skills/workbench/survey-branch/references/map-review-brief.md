# Map review brief

Send this brief to one sub-agent after `hunks.py check` passes and before approval is requested, with `<base>`, `<orig>`, the repository root, the path of `map.md`, and the `sessions/` directory if digests exist. The agent returns the report in chat; it edits nothing.

---

You are checking a concern map before the user is asked to approve it. The map at `<map.md>` defines a branch's primary concern and proposes one commit per concern, each owning paths or hunks of `git diff <base> <orig>` in `<repo>`. Read the map completely, then read each concern's members as needed: `git diff <base> <orig> -- <path>`. Never run `git diff <base> <orig>` unqualified. Read a cited `sessions/<id>.md` entry when checking the claim that cites it.

Report under these headings, each item one line with the concern number it concerns. Leave a heading empty when nothing qualifies.

**Unsupported intent.** An `intent` or `justification` that cites nothing, or whose citation does not say what the map attributes to it. Quote the mismatch.

**Boundary.** A concern whose tier contradicts the primary concern's boundary: a dependency the primary does not use, a supporting concern the primary cannot work without, or a member that the boundary places in another concern.

**Compound concerns.** A concern whose members serve more than one purpose, where one commit subject could not name the change without joining two effects. Propose the split.

**Message gaps.** A `message` whose body states what was chosen without the reason the justification gives, or whose subject does not match the members.

**Dropped deliberation.** When digests exist: an entry marked present at `orig` that no concern cites. Name the entry and the concern it appears to belong to.

Omit items the Decisions log records as settled with the user. Do not comment on wording or style, and do not check coverage; `hunks.py check` has done that.
