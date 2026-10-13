#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: prepare-worktree.sh [--source DIR] [--dry-run] [--item NAME]... [WORKTREE]

Prepare untracked dependency paths from the main worktree in WORKTREE
(default: current directory).

vendor is a local directory, cloned when supported and copied otherwise.
Reuse requires matching composer.lock files; Composer regenerates the local
autoload files without running scripts or plugins. Other items are symlinked.

The source is the main worktree: the first entry of `git worktree list`,
which git defines as the original checkout. No naming or path convention is
assumed. Use --source when the repo is bare or the main worktree is elsewhere.

Options:
  --source DIR   Reuse dependencies from DIR instead of the main worktree
  --item NAME    Path to prepare, relative to the tree root; repeatable.
                 Default: node_modules vendor .env
  --dry-run      Report what would be prepared without changing anything

An item is prepared only if it exists in the source, is not tracked by git in
the worktree, and does not already exist there. Re-running is safe.

Output: one line per item: "prepared|linked|exists|missing|tracked|skipped <name>".
Errors go to stderr with a nonzero exit status.
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
  echo "Target is the source tree; nothing to prepare." >&2
  exit 0
fi

for item in "${items[@]}"; do
  src="$source_dir/$item"
  dst="$target/$item"
  if [ ! -e "$src" ]; then echo "missing $item"; continue; fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then echo "exists $item"; continue; fi
  if [ -n "$(git -C "$target" ls-files -- "$item")" ]; then echo "tracked $item"; continue; fi
  if [ "$item" = vendor ]; then
    if [ ! -f "$source_dir/composer.lock" ] || [ ! -f "$target/composer.lock" ] ||
       ! cmp -s "$source_dir/composer.lock" "$target/composer.lock"; then
      echo "Cannot reuse vendor: source and target need matching composer.lock files. Try: composer install in $target" >&2
      exit 1
    fi
    copy_args=(-R)
    copy_method=copy
    if cp --help 2>/dev/null | grep -- --reflink >/dev/null; then
      copy_args+=("--reflink=auto")
      copy_method="reflink/copy"
    elif [ "$(uname -s)" = Darwin ]; then
      copy_args=(-cR)
      copy_method="clone/copy"
    fi
    if [ "$dry_run" -eq 1 ]; then
      echo "skipped vendor (dry run: would $copy_method from $src and generate local autoload)"
      continue
    fi
    command -v composer >/dev/null ||
      { echo "Composer not found. Try: install Composer before preparing vendor" >&2; exit 1; }
    vendor_stage=$(mktemp -d "$target/.vendor-prepare.XXXXXX")
    trap 'rm -rf -- "$vendor_stage"' EXIT
    cp "${copy_args[@]}" "$src/." "$vendor_stage"
    (
      cd "$target"
      COMPOSER_VENDOR_DIR="$vendor_stage" composer dump-autoload --no-scripts --no-plugins --no-interaction --quiet
    )
    mv "$vendor_stage" "$dst"
    trap - EXIT
    echo "prepared vendor -> $dst ($copy_method; local autoload)"
    continue
  fi
  if [ "$dry_run" -eq 1 ]; then echo "skipped $item (dry run: would link to $src)"; continue; fi
  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  echo "linked $item -> $src"
done
