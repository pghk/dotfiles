#!/usr/bin/env bash
# Copy the current branch to a trash/<branch>/<month-day-hour-minute> sibling.
set -euo pipefail

current_branch=$(git branch --show-current)
timestamp=$(date +%a-%H%M)
trash_branch="trash/${current_branch}/${timestamp}"

# Check for conflicting ancestor branches (e.g. trash/RAV-15948 when creating trash/RAV-15948/prep/...)
find_conflicts() {
    local target="$1"
    local prefix=""
    local IFS='/'
    read -ra parts <<< "$target"
    unset IFS

    # Check each prefix path (excluding full target)
    for ((i = 0; i < ${#parts[@]} - 1; i++)); do
        if [[ -z "$prefix" ]]; then
            prefix="${parts[i]}"
        else
            prefix="${prefix}/${parts[i]}"
        fi

        if git show-ref --verify --quiet "refs/heads/${prefix}"; then
            printf '%s\n' "$prefix"
        fi
    done
}

# Capture any branch creation errors
if ! err_out=$(git branch "$trash_branch" 2>&1); then
    echo "$err_out" >&2
    echo >&2

    # Diagnose potential ancestor ref collisions
    conflicts=($(find_conflicts "$trash_branch"))
    if [[ ${#conflicts[@]} -gt 0 ]]; then
        echo "Ref collision detected: Git cannot create '$trash_branch' because the following parent branch exists:" >&2
        for conflict in "${conflicts[@]}"; do
            echo "  - $conflict" >&2
        done
        echo >&2
        echo "To resolve, rename or delete the conflicting branch:" >&2
        for conflict in "${conflicts[@]}"; do
            suggested_rename="${conflict}.bak"
            echo "  git branch -m \"$conflict\" \"$suggested_rename\"" >&2
            echo "  # or: git branch -D \"$conflict\"" >&2
        done
        echo >&2
    fi

    exit 1
fi

echo "Copied $current_branch → $trash_branch"
