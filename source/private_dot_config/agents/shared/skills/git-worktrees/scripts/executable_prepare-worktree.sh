#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: prepare-worktree.sh [--source DIR] [--dry-run] [--item NAME]... [WORKTREE]

Symlink untracked dependency paths from the main worktree into WORKTREE
(default: current directory).

The source is the main worktree: the first entry of `git worktree list`,
which git defines as the original checkout. No naming or path convention is
assumed. Use --source when the repo is bare or the main worktree is elsewhere.

Options:
  --source DIR   Link from DIR instead of the main worktree
  --item NAME    Path to link, relative to the tree root; repeatable.
                 Default: node_modules vendor .env
  --dry-run      Report what would be linked without changing anything

An item is linked only if it exists in the source, is not tracked by git in
the worktree, and does not already exist there. Re-running is safe.

Output: one line per item: "linked|exists|missing|tracked|skipped <name>".
EOF
}

source_dir="" dry_run=0 items=() target="."
while [ $# -gt 0 ]; do
  case "$1" in
    --source) source_dir="${2:?--source needs a directory}"; shift 2 ;;
    --item) items+=("${2:?--item needs a name}"); shift 2 ;;
    --dry-run) dry_run=1; shift ;;
    -h|--help) usage; exit 0 ;;
    -*) echo "Unknown option $1. Try: --help" >&2; exit 2 ;;
    *) target="$1"; shift ;;
  esac
done
[ ${#items[@]} -gt 0 ] || items=(node_modules vendor .env)

target=$(git -C "$target" rev-parse --show-toplevel 2>/dev/null) ||
  { echo "Not inside a git worktree: $target. Try: pass the worktree path as an argument" >&2; exit 1; }

if [ -z "$source_dir" ]; then
  listing=$(git -C "$target" worktree list --porcelain)
  if printf '%s\n' "$listing" | sed -n '2,3p' | grep -qx bare; then
    echo "Main entry is a bare repository. Try: --source <worktree with dependencies>" >&2
    exit 1
  fi
  source_dir=$(printf '%s\n' "$listing" | sed -n '1s/^worktree //p')
fi
[ -d "$source_dir" ] || { echo "Source not found: $source_dir. Try: --source DIR" >&2; exit 1; }
source_dir=$(cd "$source_dir" && pwd -P)

if [ "$source_dir" = "$(cd "$target" && pwd -P)" ]; then
  echo "Target is the source tree; nothing to link." >&2
  exit 0
fi

for item in "${items[@]}"; do
  src="$source_dir/$item"
  dst="$target/$item"
  if [ ! -e "$src" ]; then echo "missing $item"; continue; fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then echo "exists $item"; continue; fi
  if [ -n "$(git -C "$target" ls-files -- "$item")" ]; then echo "tracked $item"; continue; fi
  if [ "$dry_run" -eq 1 ]; then echo "skipped $item (dry run: would link to $src)"; continue; fi
  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  echo "linked $item -> $src"
done
