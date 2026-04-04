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
  git trash-delete [--bulk] [--dry-run] [--days <N>]

Delete local branches in the trash/ namespace whose most recent commit
is older than the age threshold (default: 90 days).

Options:
  -b, --bulk      Bulk mode: list all candidates, then confirm all at once.
                  Default: one-by-one mode, prompting [y]es/[n]o/[q]uit per branch.
  -n, --dry-run   Preview what would be deleted without making any changes.
      --days <N>  Age threshold in days (default: 90). Branches whose most
                  recent commit is older than N days are offered for deletion.
  -h, --help      Show this help text.

Examples:
  git trash-delete                          # one-by-one interactive (90-day threshold)
  git trash-delete --bulk                   # show all candidates, confirm all
  git trash-delete --days 30 --bulk --dry-run  # preview with 30-day threshold
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
threshold_days=90

while [[ $# -gt 0 ]]; do
    case "$1" in
        -b|--bulk)     bulk=1 ;;
        -n|--dry-run)  dry_run=1 ;;
        --days)
            [[ -n "${2:-}" ]] || die "--days requires a numeric argument."
            [[ "$2" =~ ^[0-9]+$ ]] || die "--days value must be a positive integer."
            threshold_days="$2"
            shift
            ;;
        -h|--help)     usage; exit 0 ;;
        *) die "Unknown option: '$1'. Try: git trash-delete --help" ;;
    esac
    shift
done

#----------------------------------------
# Collect candidates: trash/* branches older than threshold
#----------------------------------------
now=$(date +%s)
threshold_seconds=$(( threshold_days * 86400 ))

candidates=()
candidate_ages=()  # human-readable age for display

while IFS= read -r branch; do
    last_commit_ts=$(git log -1 --format="%ct" "$branch" 2>/dev/null) || continue
    age_seconds=$(( now - last_commit_ts ))
    if (( age_seconds >= threshold_seconds )); then
        age_days=$(( age_seconds / 86400 ))
        candidates+=("$branch")
        candidate_ages+=("${age_days}d")
    fi
done < <(git for-each-ref --format='%(refname:short)' refs/heads | grep '^trash/' | sort)

if [[ ${#candidates[@]} -eq 0 ]]; then
    printf "No trash/ branches older than %d days found.\n" "$threshold_days"
    exit 0
fi

#----------------------------------------
# Helper: delete one branch
#----------------------------------------
delete_branch() {
    local branch="$1"
    if [[ "$dry_run" -eq 1 ]]; then
        printf "  [dry-run] would delete: %s\n" "$branch"
    else
        git branch -D "$branch"
        printf "  Deleted: %s\n" "$branch"
    fi
}

#----------------------------------------
# One-by-one mode (default)
#----------------------------------------
if [[ "$bulk" -eq 0 ]]; then
    [[ "$dry_run" -eq 1 ]] && printf "(dry-run mode — no changes will be made)\n\n"
    deleted=0
    skipped=0
    for i in "${!candidates[@]}"; do
        branch="${candidates[$i]}"
        age="${candidate_ages[$i]}"
        while true; do
            printf "Delete? %s  (last commit: %s ago)\n  [y]es / [n]o / [q]uit: " "$branch" "$age"
            read -r answer </dev/tty
            case "$answer" in
                y|Y|yes)
                    delete_branch "$branch"
                    (( deleted++ )) || true
                    break
                    ;;
                n|N|no|"")
                    printf "  Skipped.\n"
                    (( skipped++ )) || true
                    break
                    ;;
                q|Q|quit|exit)
                    printf "Quit. Deleted %d, skipped %d.\n" "$deleted" "$skipped"
                    exit 0
                    ;;
                *)
                    printf "  Please enter y, n, or q.\n"
                    ;;
            esac
        done
    done
    printf "\nDone. Deleted %d, skipped %d.\n" "$deleted" "$skipped"
    exit 0
fi

#----------------------------------------
# Bulk mode
#----------------------------------------
[[ "$dry_run" -eq 1 ]] && printf "(dry-run mode — no changes will be made)\n"
printf "\n%d trash/ branch(es) older than %d days:\n" "${#candidates[@]}" "$threshold_days"
for i in "${!candidates[@]}"; do
    printf "  %s  (%s old)\n" "${candidates[$i]}" "${candidate_ages[$i]}"
done

if [[ "$dry_run" -eq 1 ]]; then
    exit 0
fi

printf "\nPermanently delete all %d branch(es)? [y/N]: " "${#candidates[@]}"
read -r answer </dev/tty
if [[ "$answer" == y || "$answer" == Y || "$answer" == yes ]]; then
    for branch in "${candidates[@]}"; do
        delete_branch "$branch"
    done
    printf "\nDone. Deleted %d branch(es).\n" "${#candidates[@]}"
else
    printf "Aborted. No branches were deleted.\n"
fi
