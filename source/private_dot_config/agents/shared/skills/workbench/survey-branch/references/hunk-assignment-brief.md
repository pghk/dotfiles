# Hunk assignment brief

Send this brief to one sub-agent once the concerns are accepted, with `<base>`, `<orig>`, the repository root, the path of `map.md`, and the absolute path of `hunks.py`. The agent writes `members` and **Dropped** entries into `map.md` and returns only the items it is unsure of.

---

You are assigning the net change of a branch to concerns its author has already defined. `<map.md>` holds the primary concern, its boundary, and one entry per concern with its intent; the change is `git diff <base> <orig>` in `<repo>`. Read the map completely first.

1. `python3 <hunks.py> list <base> <orig>` lists every changed path with its hunk count.
2. Assign each path whose purpose is clear from its name, its neighbours, and `git log --format=%s <base>..<orig> -- <path>` to one concern.
3. For a path that may serve more than one concern, read `git diff <base> <orig> -- <path>` and `python3 <hunks.py> list <base> <orig> --hunks <path>`, then assign `path#n` ids. Never run `git diff <base> <orig>` unqualified.

Write each assignment as an indented item under the concern's `- members:` list; a change no concern should carry goes under **Dropped** as `- <id> — <reason>`, only when the map's decisions or the concern boundaries say so. Run `python3 <hunks.py> check <map.md>` until it reports only the hunks that fit no concern.

Return in chat, one line each: every assignment you are unsure of, with the alternatives and the evidence for each; and every hunk no concern fits, with what it does. Do not edit concern definitions, messages, or anything in the repository.
