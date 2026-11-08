---
name: git-worktrees
description: >
  Create, prepare, integrate, or retire a git worktree and its local dependencies.
---

# Git worktrees

## Create

Place linked checkouts at `<main-parent>/worktrees/<main-basename>/<task>`. Resolve the main checkout through Git, including when creating from a linked tree. Use a short task directory name independently of the branch name. Name the start point explicitly so the branch does not inherit whatever the main checkout has checked out.

```bash
main=$(git worktree list --porcelain | sed -n '1s/^worktree //p')
task="<task>"
branch="<branch>"
start_point="<start-point>"
target="$(dirname "$main")/worktrees/$(basename "$main")/$task"
mkdir -p "$(dirname "$target")"
git -C "$main" worktree add "$target" -b "$branch" "$start_point"
bash <skill-dir>/scripts/prepare-worktree.sh "$target"
```

## Prepare

The script clones `vendor` with copy-on-write when supported, otherwise copies it, and regenerates local autoload files with `--no-scripts --no-plugins`. Reuse requires matching `composer.lock` files; otherwise run `composer install` in the target. Existing paths are preserved.

It symlinks `node_modules` and `.env`.

The preparation source is the main worktree, the first entry of `git worktree list`. For a bare repository, identify an existing persistent checkout and set `main` to that path before calculating `target`; pass `--source "$main"` when preparing it. For a different dependency source, pass `--source DIR`.

Pass `--item NAME` (repeatable) to select untracked paths, replacing the default list; items other than `vendor` are symlinked. Use `--dry-run` to preview and `--help` for flags.

`vendor` is independent. Installing into linked `node_modules` or editing linked `.env` changes the source. When a branch changes its JavaScript lockfile, replace the `node_modules` link with a local install.

Validate script changes with `python3 <skill-dir>/scripts/test_prepare_worktree.py` (Git, PHP, Composer). Set `WORKTREE_PEST_SOURCE` to a checkout with Pest installed to include its disposable-worktree test.

## Integrate

Run only when the user directs integration. Name the source branch, the target branch, and the persistent checkout that holds the target.

1. **Settle contributors.** Do not rewrite a branch while another worktree or session is based on commits that will be rewritten. Finish or incorporate them first.
2. **Check the source worktree.** `git -C <worktree> status --short` must be empty. Commit uncommitted changes into the work or discard them with the user's agreement.
3. **Tidy in the source worktree**, where the context and dependencies are. First snapshot the raw history as `trash/<branch>` (`git branch trash/<branch>`; it is the only copy kept), then rebase onto the target's current tip and rewrite into concise commits by concern (the `commit` skill governs messages). Fold commits whose only purpose is to correct or complete an earlier commit into that commit. Rerun the verification the branch claims.
4. **Integrate.** Use `git merge --ff-only <branch>` from the target checkout when every tidied commit should land. Cherry-pick the chosen commits when only part should land or the target has moved. Do not create a merge commit or land untidied history.
5. **Verify the target.** Confirm its history and content match the tidied branch, and rerun the claimed verification there, especially after cherry-picks or conflict resolution.

Do not push.

## Retire

Run only when the user requests cleanup, which they may do together with integration. Each worktree needs an explicit disposition from the user, including worktrees whose work was abandoned. Worktree removal discards ignored files.

Run from the persistent checkout, not from inside the worktree. Remove the worktree, then dispose of its branch:

- **Integrated branch** (tidied and landed): delete it. Its content is on the target and the raw history is already `trash/<branch>`.
- **Branch never integrated** (abandoned, or a subagent branch without a raw snapshot): rename it to `trash/<branch>` so its work stays recoverable.

```bash
git -C "$main" worktree remove "$worktree"
git -C "$main" branch -d "$branch"              # integrated
git -C "$main" branch -m "$branch" "trash/$branch"   # not integrated
```

`-d` refuses a branch that is not an ancestor of the target. After a cherry-pick, verify that every commit landed, then use `-D`.

Before removing:

- `git -C "$worktree" status --short` is empty.
- Ignored worktree-local files are inspected (`git -C "$worktree" status --short --ignored`). Dependencies the preparation script created are disposable; measurements, screenshots, logs, and generated evidence are kept or recorded first. Symlinked `node_modules` and `.env` targets survive.
- The worktree is on a branch; a detached HEAD has nothing to rename and needs a decision from the user.
- `trash/$branch` does not exist and does not collide with a branch namespace (`trash/pi-subagents` blocks `trash/pi-subagents/task-1`). Resolve conflicts by choosing another name; never force with `-M`.

Never use `git worktree remove --force` or `rm -rf` on a worktree. If a worktree path vanished externally, inspect `git worktree prune --dry-run` before pruning.

`trash/*` branches stay for later reference and are deleted only when the user asks.
