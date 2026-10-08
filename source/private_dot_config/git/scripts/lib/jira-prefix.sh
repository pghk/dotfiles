# Sourced helper. Prints "KEY-123 - " when the branch name contains a Jira key.
# Usage: jira_prefix [<branch>]   (defaults to the current branch)

jira_prefix() {
  local branch="${1-$(git branch --show-current)}"
  if [[ "$branch" =~ [A-Z]+-[0-9]+ ]]; then
    printf '%s - ' "${BASH_REMATCH[0]}"
  fi
  return 0
}
