---
name: git-worktrees
description: >
  Create or prepare a git worktree and its local dependencies.
---

# Git worktrees

## Create

Place linked checkouts at `<main-parent>/worktrees/<main-basename>/<task>`. Resolve the main checkout through Git, including when creating from a linked tree. Use a short task directory name independently of the branch name.

```bash
main=$(git worktree list --porcelain | sed -n '1s/^worktree //p')
task="<task>"
branch="<branch>"
target="$(dirname "$main")/worktrees/$(basename "$main")/$task"
mkdir -p "$(dirname "$target")"
git -C "$main" worktree add "$target" -b "$branch"
bash <skill-dir>/scripts/prepare-worktree.sh "$target"
```

The script clones `vendor` with copy-on-write when supported, otherwise copies it, and regenerates local autoload files with `--no-scripts --no-plugins`. Reuse requires matching `composer.lock` files; otherwise run `composer install` in the target. Existing paths are preserved.

It symlinks `node_modules` and `.env`; agents often cannot read or write `.env` directly.

## Source

The preparation source is the main worktree, the first entry of `git worktree list`. For a bare repository, identify an existing persistent checkout and set `main` to that path before calculating `target`; pass `--source "$main"` when preparing it. For a different dependency source, pass `--source DIR`.

Pass `--item NAME` (repeatable) to select untracked paths, replacing the default list; items other than `vendor` are symlinked. Use `--dry-run` to preview and `--help` for flags.

## Shared state

`vendor` is independent. Installing into linked `node_modules` or editing linked `.env` changes the source. When a branch changes its JavaScript lockfile, replace the `node_modules` link with a local install.

Validate script changes with `python3 <skill-dir>/scripts/test_prepare_worktree.py` (Git, PHP, Composer). Set `WORKTREE_PEST_SOURCE` to a checkout with Pest installed to include its disposable-worktree test.
