#!/usr/bin/env bash
# git-trash-should-mark.sh — Hook for git-trash-mark auto-suggestion
#
# USAGE
#   git-trash-should-mark.sh <branch-name>
#
# CONTRACT
#   Exit 0   → mark this branch (it is considered stale)
#   Non-zero → keep this branch (not stale, or determination failed)

JIRA_HOST=$(git config --get git-work.jiraHost)
JIRA_USER=$(git config --get user.email)

branch="${1:-}"
[[ -z "$branch" ]] && exit 1

ticket=$(echo "$branch" | grep -oE '[A-Z]+-[0-9]+' | head -1)
[[ -z "$ticket" ]] && exit 1

# File-based cache: one file per ticket, 1-hour TTL.
# Avoids redundant API calls when multiple branches share the same ticket.
cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/git-branch-is-deletable"
cache_file="$cache_dir/$ticket"
cache_ttl=3600

if [[ -f "$cache_file" ]]; then
    now=$(date +%s)
    mtime=$(stat -f %m "$cache_file")
    if (( now - mtime < cache_ttl )); then
        cached=$(cat "$cache_file")
        [[ "$cached" == "done" ]] && exit 0
        exit 1
    fi
fi

JIRA_TOKEN=$(security find-generic-password -a "$JIRA_USER" -s "$JIRA_HOST" -w)

status=$(curl -sf -u "$JIRA_USER:$JIRA_TOKEN" \
  "https://${JIRA_HOST}/rest/api/3/issue/${ticket}?fields=status" \
  | jq -r '.fields.status.statusCategory.key')

mkdir -p "$cache_dir"
printf '%s' "$status" > "$cache_file"

[[ "$status" == "done" ]] && exit 0

exit 1
