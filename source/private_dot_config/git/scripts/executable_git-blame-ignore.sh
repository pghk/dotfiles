#!/usr/bin/env bash
# git-blame-ignore — add a commit to the blame.ignoreRevsFile
# Usage:
#   git blame-ignore [<commit>]
# Defaults to HEAD if no commit is given.

set -euo pipefail

sha="${1:-HEAD}"

ignore_file=$(git config blame.ignoreRevsFile)
if [[ -z "$ignore_file" ]]; then
  echo "error: blame.ignoreRevsFile is not configured" >&2
  exit 1
fi

# Ensure trailing newline before appending
if [[ -e "$ignore_file" && -n "$(tail -c 1 "$ignore_file")" ]]; then
  echo >> "$ignore_file"
fi

# Append comment line with short subject + full SHA
git show -s --format="# %s%n%H%n" "$sha" >> "$ignore_file"

# Add and commit
short_sha=$(git rev-parse --short "$sha")
prefix=""
branch=$(git branch --show-current)
if jira_key=$(echo "$branch" | grep -oE '[A-Z]+-[0-9]+' | head -1); then
  prefix="$jira_key - "
fi

git add "$ignore_file"
git commit -m "${prefix}Exclude $short_sha from annotations"