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

JIRA_TOKEN=$(security find-generic-password -a $JIRA_USER -s $JIRA_HOST -w)

branch="${1:-}"
[[ -z "$branch" ]] && exit 1

ticket=$(echo "$branch" | grep -oE '[A-Z]+-[0-9]+' | head -1)
[[ -z "$ticket" ]] && exit 1

status=$(curl -sf -u "$JIRA_USER:$JIRA_TOKEN" \
  "https://${JIRA_HOST}/rest/api/3/issue/${ticket}?fields=status" \
  | jq -r '.fields.status.statusCategory.key')

[[ "$status" == "done" ]] && exit 0

exit 1
