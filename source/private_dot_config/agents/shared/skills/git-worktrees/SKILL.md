---
name: git-worktrees
description: >
  Create or prepare a git worktree and its local dependencies.
---

# Git worktrees

## Create

```
git worktree add ../<name> -b <branch>
bash <skill-dir>/scripts/prepare-worktree.sh ../<name>
```

The script clones `vendor` with copy-on-write when supported, otherwise copies it, and regenerates local autoload files with `--no-scripts --no-plugins`. Reuse requires matching `composer.lock` files; otherwise run `composer install` in the target. Existing paths are preserved.

It symlinks `node_modules` and `.env`; agents often cannot read or write `.env` directly.

## Source

The source is the main worktree, the first entry of `git worktree list`. Git records it, so no directory naming or sibling layout is assumed. For a bare repository or a different source, pass `--source DIR`.

Pass `--item NAME` (repeatable) to select untracked paths, replacing the default list; items other than `vendor` are symlinked. Use `--dry-run` to preview and `--help` for flags.

## Shared state

`vendor` is independent. Installing into linked `node_modules` or editing linked `.env` changes the source. When a branch changes its JavaScript lockfile, replace the `node_modules` link with a local install.

Validate script changes with `python3 <skill-dir>/scripts/test_prepare_worktree.py` (Git, PHP, Composer). Set `WORKTREE_PEST_SOURCE` to a checkout with Pest installed to include its disposable-worktree test.
