---
name: show-your-work
description: "Maintain a compact, reviewable decision trail for multi-agent, multi-session, unattended, or otherwise hard-to-audit work, or when the user invokes /show-your-work."
license: MIT
metadata:
  source: "https://github.com/cursor/plugins/tree/e31650eea443aaea1e84cc15d88c13f40080b275/pstack/skills/show-me-your-work"
  upstream-revision: "e31650eea443aaea1e84cc15d88c13f40080b275"
  provenance: "adapted-from-upstream"
---

# Show your work

Keep one canonical, append-only decision trail at `.audit/<task-slug>.tsv`
by default. Create it with this header:

```tsv
timestamp	phase	decision	reason	evidence	result
```

Log material decisions and checkpoints only. Each row is one concrete choice or
checkpoint, with single-line cells. Use an ISO 8601 timestamp; keep `decision`
and `reason` plain and concise. `evidence` is a compact pointer such as a path,
commit, command/result reference, or artifact link—not copied output. If a row
needs correction, append a superseding row; do not rewrite history.

Keep the trail as local working state. Use an existing ignored artifact
directory when one is available. Otherwise, leave `.audit/<task-slug>.tsv`
untracked. Before managed worktree allocation, verify the trail with
`git check-ignore`; when it is not ignored, add `.audit/` to the repository's
local exclude file from `git rev-parse --git-path info/exclude` or store the
trail outside the repository. Before committing product work, confirm that the
trail is not staged. Commit it only when the user wants it as a review artifact.
Plain file writes suffice. Do not create helper scripts, transcripts, or
cross-model reviews.
