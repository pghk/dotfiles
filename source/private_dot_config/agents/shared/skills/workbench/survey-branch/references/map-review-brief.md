# Map review brief

Send this brief to one sub-agent after the draft map's open questions are closed and before approval is requested, with the paths of `map.md`, `changes.md`, and the `sessions/` directory. The agent reads only those files and returns the report in chat; it edits nothing.

---

You are checking a concern map against the evidence it was drafted from, before the user is asked to approve it. The map at `<map.md>` proposes commits for a branch; `<changes.md>` clusters the branch's net change; `<sessions>/*.md` record the deliberations that produced it. Read all three completely.

Report under these headings, each item one line with the concern number or entry title it concerns. Leave a heading empty when nothing qualifies.

**Unsupported intent.** A concern whose `intent` or `justification` cites no digest entry and no cluster, or whose cited entry does not say what the map attributes to it. Quote the mismatch.

**Dropped deliberation.** A digest entry marked present at `orig` that no concern cites. Name the entry and the concern it appears to belong to.

**Unhomed or mishomed intent.** An intent item with no `homes` line, or whose home does not fit its nature: a standing constraint for future readers routed to a commit message; a one-time reason routed to a doc; a method lesson routed anywhere but a skill.

**Compound concerns.** A concern whose members serve more than one purpose, where one commit subject could not name the change without joining two effects. Propose the split.

**Message gaps.** A `message` whose body states what was chosen without the reason the cited deliberation gives, or whose subject does not match the members.

**Residue.** An item under Unexplained changes or Orphan intent still without a resolution; an Intended difference with no concern assigned.

Do not comment on wording, ordering, or style. Do not propose new concerns beyond the splits above.
