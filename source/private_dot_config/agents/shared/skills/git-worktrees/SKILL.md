---
name: git-worktrees
description: >
  Create or prepare a git worktree, or fix one lacking vendor, node_modules, or .env by linking them from the main tree.
---

# Git worktrees

## Create

```
git worktree add ../<name> -b <branch>
bash <skill-dir>/scripts/prepare-worktree.sh ../<name>
```

The script symlinks `node_modules`, `vendor`, and `.env` from the main worktree into the new one. A fresh worktree has none of these because they are untracked. Run it instead of copying `.env` or reinstalling; agents often cannot read or write `.env` directly.

## Source of the links

The source is the main worktree, the first entry of `git worktree list`. Git records it, so no directory naming or sibling layout is assumed. For a bare repository or a different source, pass `--source DIR`.

Pass `--item NAME` (repeatable) to link other untracked paths, replacing the default list. Use `--dry-run` to preview; `--help` lists flags.

## Shared state

A link is not a copy. Installing or upgrading dependencies from inside the worktree modifies the main tree's `node_modules`/`vendor`, and editing `.env` changes it everywhere. When a branch changes the lockfile, replace that link with a real install: remove the symlink, then run the package manager in the worktree.
