#!/usr/bin/env bash
set -euo pipefail

#----------------------------------------
# Utility
#----------------------------------------

die() {
    printf "Error: %s\n" "$*" >&2
    exit 1
}

usage() {
    cat <<'EOF'
Usage:
  git trash-mark [--bulk] [--dry-run]

Suggest and mark local branches for deletion by renaming them to
trash/<original-name>. Candidates are determined by two criteria:

  1. [merged] Branches fully merged into the configured base remote branch
             (default: origin/develop; configure with git-work.basePr)
  2. [flagged]  Branches flagged by the optional hook script:
             $XDG_CONFIG_HOME/git/scripts/git-trash-should-mark.sh <branch>
             Hook exits 0 → mark this branch; non-zero → keep it.
             Missing or erroring hook is always safe (branches are kept).

Options:
  -b, --bulk      Bulk mode: list all candidates, then confirm all at once.
                  Default: one-by-one mode, prompting [y]es/[n]o/[q]uit per branch.
  -n, --dry-run   Preview what would be renamed without making any changes.
  -h, --help      Show this help text.

Examples:
  git trash-mark                     # one-by-one interactive
  git trash-mark --bulk              # show all candidates, confirm all
  git trash-mark --bulk --dry-run    # preview only
EOF
}

#----------------------------------------
# Ensure we are inside a Git repo
#----------------------------------------
git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
    || die "Not inside a git repository."

#----------------------------------------
# Parse arguments
#----------------------------------------
bulk=0
dry_run=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        -b|--bulk)     bulk=1 ;;
        -n|--dry-run)  dry_run=1 ;;
        -h|--help)     usage; exit 0 ;;
        *) die "Unknown option: '$1'. Try: git trash-mark --help" ;;
    esac
    shift
done

#----------------------------------------
# Build protected-branch list
#----------------------------------------
current_branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)" || current_branch=""

is_protected() {
    local branch="$1"
    [[ "$branch" == trash/* ]]         && return 0
    [[ "$branch" == "$current_branch" ]] && return 0
    case "$branch" in
        main|master|develop|local/*) return 0 ;;
    esac
    return 1
}

#----------------------------------------
# Resolve base remote branch for merge check
#----------------------------------------
base_ref="$(git config --get git-work.basePr 2>/dev/null || printf 'origin/develop')"

#----------------------------------------
# Auto-fetch origin to ensure remote-tracking refs are current
#----------------------------------------
remote="${base_ref%%/*}"
remote_branch="${base_ref#*/}"
if git remote get-url "$remote" >/dev/null 2>&1; then
    printf "Fetching %s/%s…\n" "$remote" "$remote_branch"
    git fetch "$remote" "${remote_branch}:refs/remotes/${remote}/${remote_branch}" --quiet
fi

# Verify the base ref actually exists after fetch
git rev-parse --verify "$base_ref" >/dev/null 2>&1 \
    || die "Base ref '$base_ref' not found. Configure with: git config git-work.basePr <ref>"

#----------------------------------------
# Locate optional external check
#----------------------------------------
hook_script="${XDG_CONFIG_HOME:-$HOME/.config}/git/scripts/git-branch-is-deletable.sh"
has_hook=0
[[ -x "$hook_script" ]] && has_hook=1

#----------------------------------------
# Collect and classify candidates
#   candidates[]      — branch names
#   candidate_tags[]  — display tag: [merged] or [flagged]
#----------------------------------------
candidates=()
candidate_tags=()

while IFS= read -r branch; do
    is_protected "$branch" && continue

    # Criterion 1: merged into base ref
    if git merge-base --is-ancestor "$branch" "$base_ref" 2>/dev/null; then
        candidates+=("$branch")
        candidate_tags+=("[merged]")
        continue
    fi

    # Criterion 2: hook says to mark (exit 0 = mark; non-zero = keep)
    if [[ "$has_hook" -eq 1 ]]; then
        if "$hook_script" "$branch" 2>/dev/null; then
            candidates+=("$branch")
            candidate_tags+=("[flagged]")
        fi
    fi
done < <(git for-each-ref --format='%(refname:short)' refs/heads | sort)

if [[ ${#candidates[@]} -eq 0 ]]; then
    printf "No branches suggested for trash.\n"
    exit 0
fi

#----------------------------------------
# Helper: resolve a non-colliding trash target name.
# If trash/<branch> exists, try trash/<branch>.2, .3, … until free.
#----------------------------------------
resolve_trash_target() {
    local branch="$1"
    local base="trash/${branch}"
    local target="$base"
    local n=2
    while git rev-parse --verify --quiet "$target" >/dev/null 2>&1; do
        target="${base}.${n}"
        (( n++ ))
    done
    printf '%s' "$target"
}

#----------------------------------------
# Helper: rename one branch (collision-safe)
#----------------------------------------
rename_branch() {
    local branch="$1"
    local target
    target="$(resolve_trash_target "$branch")"
    if [[ "$dry_run" -eq 1 ]]; then
        printf "  [dry-run] would rename: %s → %s\n" "$branch" "$target"
    else
        git branch -m "$branch" "$target"
        printf "  Renamed: %s → %s\n" "$branch" "$target"
    fi
}

#----------------------------------------
# One-by-one mode (default)
#----------------------------------------
if [[ "$bulk" -eq 0 ]]; then
    [[ "$dry_run" -eq 1 ]] && printf "(dry-run mode — no changes will be made)\n\n"
    marked=0
    skipped=0
    for i in "${!candidates[@]}"; do
        branch="${candidates[$i]}"
        tag="${candidate_tags[$i]}"
        while true; do
            printf "Mark for trash? %s  %s\n  [y]es / [n]o / [q]uit: " "$branch" "$tag"
            read -r answer </dev/tty
            case "$answer" in
                y|Y|yes)
                    rename_branch "$branch"
                    (( marked++ )) || true
                    break
                    ;;
                n|N|no|"")
                    printf "  Skipped.\n"
                    (( skipped++ )) || true
                    break
                    ;;
                q|Q|quit|exit)
                    printf "Quit. Marked %d, skipped %d.\n" "$marked" "$skipped"
                    exit 0
                    ;;
                *)
                    printf "  Please enter y, n, or q.\n"
                    ;;
            esac
        done
    done
    printf "\nDone. Marked %d, skipped %d.\n" "$marked" "$skipped"
    exit 0
fi

#----------------------------------------
# Bulk mode
#----------------------------------------
[[ "$dry_run" -eq 1 ]] && printf "(dry-run mode — no changes will be made)\n"
printf "\n%d branch(es) suggested for trash:\n" "${#candidates[@]}"
for i in "${!candidates[@]}"; do
    printf "  %-10s %s → %s\n" "${candidate_tags[$i]}" "${candidates[$i]}" "$(resolve_trash_target "${candidates[$i]}")"
done

if [[ "$dry_run" -eq 1 ]]; then
    exit 0
fi

printf "\nMark all %d branch(es) for trash? [y/N]: " "${#candidates[@]}"
read -r answer </dev/tty
if [[ "$answer" == y || "$answer" == Y || "$answer" == yes ]]; then
    for branch in "${candidates[@]}"; do
        rename_branch "$branch"
    done
    printf "\nDone. Marked %d branch(es).\n" "${#candidates[@]}"
else
    printf "Aborted. No branches were renamed.\n"
fi
