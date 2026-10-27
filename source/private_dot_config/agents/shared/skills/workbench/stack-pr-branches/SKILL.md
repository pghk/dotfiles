---
name: stack-pr-branches
description: Split a clean branch into stacked PR branches with ticket-key commit messages, then write each PR's description and the stack's QA plan. Use after rebase-by-concern, before publishing.
disable-model-invocation: true
---

Turn a clean branch into stacked PR branches of reviewable size. The source branch, the checkout, the index and uncommitted changes are never touched, and nothing is pushed.

## Branch names

`<ticket>/<NNN>-<slug>`, for example `RAV-16860/010-heading-roles`. `NNN` rises in steps of 10, so order sorts without knowing the count, collapsing parts leaves gaps instead of renames, and a part can be inserted between two others. The slug names the concern, so a collapsed stack still reads. Slugs are short kebab-case, chosen by you and overridable in the manifest.

## Steps

1. Establish the range: `git rev-list --reverse <base>..<source>`. Require the source's tree to equal the intended final tree, and record the user's uncommitted changes to compare afterwards.
2. Group commits into parts. A part is one reviewable concern; a mechanical change goes first and alone-ish, so later diffs stay small. Size by what a reviewer can hold at once, not a fixed limit. Note PR bases that are not the current trunk.
3. Write a manifest (format in `scripts/stack.py --help`) and run `python3 scripts/stack.py <manifest> --dry-run`, then without `--dry-run`. It rewrites each commit with `git commit-tree` keeping tree and author, replaces the gitmoji with the ticket key, wraps the message through [commit](../../writing/commit/SKILL.md)'s wrapper, and creates every ref in one transaction.
4. Read the printed subjects; the script warns on stderr about any over 50 characters. Reword those, and any that no longer describe the part, by setting the manifest `subject` and rebuilding after deleting the created branches. A message with no body is fine.
5. Verify: each tip descends from the previous, the last tip's tree equals the source's, `git diff --check` is clean, and the checkout and uncommitted changes are unchanged.
6. Run the suites each part's layer affects; the last tip equals the tested tree, so intermediate tips are untested unless you run them. Record failures rather than fixing unrelated ones.
7. Per part, use [describe-changeset](../../writing/describe-changeset/SKILL.md); for the whole stack, [plan-qa](../../writing/plan-qa/SKILL.md). Write drafts to the session files, one paragraph per line.
