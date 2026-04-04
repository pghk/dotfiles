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
  git-work new <prefix> [variant]
  git-work pr

Commands:
  new      Create a dev-work branch: <prefix>/dev/<variant> from local/dev
           If [variant] is omitted, a context-aware default is chosen:
             - If no existing <prefix>/dev/* branches exist locally: variant = "default"
             - Else: variant = next letter after highest existing single-letter variant (a..z),
                     or "a" if none exist yet
  pr       Create a PR-ready branch by transforming /dev/ -> /main/, based on origin/develop

Notes:
  - Both commands *create* branches but never switch to them.
  - 'pr' auto-fetches origin/develop and refuses to overwrite existing branches.
EOF
}

base_dev_ref() {
  git config --get --default "local/dev" git-work.baseDev
}

base_pr_ref() {
  git config --get --default "origin/develop" git-work.basePr
}

# Fetch a remote-tracking ref like "origin/develop" in a lightweight way.
# If base is not a remote-tracking ref, this is a no-op.
fetch_remote_tracking_ref() {
  local ref="$1"

  # Match "<remote>/<branch...>"
  if [[ "$ref" == */* ]]; then
    local remote="${ref%%/*}"
    local branch="${ref#*/}"

    # Only fetch if a remote by that name exists
    if git remote get-url "$remote" >/dev/null 2>&1; then
      printf "Fetching latest %s/%s…\n" "$remote" "$branch"
      git fetch "$remote" "$branch:refs/remotes/$remote/$branch"
    fi
  fi
}

#----------------------------------------
# Ensure we are inside a Git repo
#----------------------------------------
git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
    || die "Not inside a git repository."

#----------------------------------------
# Helper: choose default variant based on existing local branches
#----------------------------------------
choose_variant() {
    local prefix="$1"
    local needle="${prefix}/dev/"

    # Gather existing variants from local branches that start with "${prefix}/dev/"
    local max_letter_code=0
    local saw_any=0

    while IFS= read -r branch; do
        # literal prefix check (avoids glob pitfalls)
        if [[ "${branch:0:${#needle}}" == "$needle" ]]; then
            saw_any=1
            local v="${branch:${#needle}}"

            # Only consider single-letter variants for sequencing
            if [[ "$v" =~ ^[a-z]$ ]]; then
                # ASCII code for the letter
                local code
                code="$(printf '%d' "'$v")"
                if (( code > max_letter_code )); then
                    max_letter_code="$code"
                fi
            fi
        fi
    done < <(git for-each-ref --format='%(refname:short)' refs/heads)

    # If nothing exists for this prefix yet, use "default"
    if (( saw_any == 0 )); then
        printf '%s' "default"
        return 0
    fi

    # If something exists but no a..z variants exist yet, start at "a"
    if (( max_letter_code == 0 )); then
        printf '%s' "a"
        return 0
    fi

    # Otherwise pick the next letter
    if (( max_letter_code >= 122 )); then
        # 'z' == 122
        return 2
    fi

    local next_code=$((max_letter_code + 1))
    # Convert ASCII code to letter
    printf "\\$(printf '%03o' "$next_code")"
}

#----------------------------------------
# Subcommand dispatch
#----------------------------------------
cmd="${1:-}"
[[ -z "$cmd" ]] && { usage; exit 1; }
shift || true

case "$cmd" in
    new)
        #----------------------------------------
        # git-work new <prefix> [variant]
        #----------------------------------------
        prefix="${1:-}"
        [[ -z "$prefix" ]] && die "Missing <prefix>. Usage: git-work new <prefix> [variant]"

        variant="${2:-}"
        if [[ -z "$variant" ]]; then
            if ! variant="$(choose_variant "$prefix")"; then
                die "Too many letter variants already exist for '${prefix}/dev/*' (a..z exhausted). Specify a variant explicitly."
            fi
            printf "Auto-selected variant: %s\n" "$variant"
        fi

        new_branch="${prefix}/dev/${variant}"
        base="$(base_dev_ref)"

        # Ensure base exists
        git rev-parse --verify "$base" >/dev/null 2>&1 \
          || die "Base branch '$base' does not exist (configure with: git config git-work.baseDev <ref>)."

        printf "Creating dev-work branch: %s (from %s)\n" "$new_branch" "$base"
        git branch "$new_branch" "$base"
        exit 0
        ;;

    pr)
        #----------------------------------------
        # git-work pr
        #----------------------------------------
        current_branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)" \
            || die "Could not determine current branch."

        [[ "$current_branch" == "HEAD" ]] && die "You are in a detached HEAD state."

        # Must contain /dev/
        if [[ "$current_branch" != *"/dev/"* ]]; then
            die "Current branch must contain '/dev/' to generate a PR branch."
        fi

        # Replace first occurrence of /dev/ with /main/ (use sed to avoid escaping quirks)
        target_branch="$(printf '%s\n' "$current_branch" | sed 's#/dev/#/main/#')"

        # No-op if already a main branch (defensive)
        if [[ "$target_branch" == "$current_branch" ]]; then
            printf "Already a main-variant branch; nothing to do.\n"
            exit 0
        fi

        # Validate target branch name early
        git check-ref-format --branch "$target_branch" >/dev/null \
          || die "Computed target branch name is invalid: '$target_branch'"

        base="$(base_pr_ref)"

        # Fetch remote-tracking base if applicable (e.g., origin/develop)
        fetch_remote_tracking_ref "$base" || die "Fetch failed."

        # Verify base exists after fetch (or if local ref)
        git rev-parse --verify "$base" >/dev/null 2>&1 \
          || die "Missing base ref '$base' (configure with: git config git-work.basePr <ref>)."

        # Ensure target does not already exist
        if git rev-parse --quiet --verify "$target_branch" >/dev/null; then
          die "Target branch '$target_branch' already exists."
        fi

        printf "Creating PR branch: %s (from %s)\n" "$target_branch" "$base"
        git branch "$target_branch" "$base"
        exit 0
        ;;

    -h|--help|help)
        usage
        exit 0
        ;;

    *)
        die "Unknown command: '$cmd'. Try: git-work --help"
        ;;
esac
