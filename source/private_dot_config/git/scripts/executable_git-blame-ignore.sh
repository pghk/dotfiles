#!/usr/bin/env bash
# git-blame-ignore — record a commit in the blame.ignoreRevsFile
# Usage:
#   git blame-ignore [<commit>]   append <commit> (default HEAD) and commit the file
#   git blame-ignore --init       set blame.ignoreRevsFile (default .git-blame-ignore-revs) and create the file
#
# Does nothing (exit 0) when blame.ignoreRevsFile is unset or empty, so callers need no gate.

set -euo pipefail

# shellcheck source=lib/jira-prefix.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib/jira-prefix.sh"

default_file=".git-blame-ignore-revs"
toplevel=$(git rev-parse --show-toplevel)

configured_file() {
  git config --type=path --get blame.ignoreRevsFile 2>/dev/null || true
}

# blame.ignoreRevsFile is resolved from the worktree root when relative.
absolute_path() {
  case "$1" in
    /*) printf '%s' "$1" ;;
    *) printf '%s/%s' "$toplevel" "$1" ;;
  esac
}

ensure_file() {
  mkdir -p "$(dirname "$1")"
  [[ -e "$1" ]] || : > "$1"
}

if [[ "${1-}" == "--init" ]]; then
  ignore_file=$(configured_file)
  if [[ -z "$ignore_file" ]]; then
    git config blame.ignoreRevsFile "$default_file"
    ignore_file="$default_file"
  fi
  path=$(absolute_path "$ignore_file")
  ensure_file "$path"
  echo "blame.ignoreRevsFile = $ignore_file ($path)" >&2
  exit 0
fi

sha="${1:-HEAD}"

ignore_file=$(configured_file)
if [[ -z "$ignore_file" ]]; then
  echo "blame-ignore: blame.ignoreRevsFile is not set; nothing to do (run 'git blame-ignore --init')" >&2
  exit 0
fi

path=$(absolute_path "$ignore_file")
ensure_file "$path"

# Ensure trailing newline before appending
if [[ -s "$path" && -n "$(tail -c 1 "$path")" ]]; then
  echo >> "$path"
fi

# Append comment line with subject + full SHA
git show -s --format="# %s%n%H%n" "$sha" >> "$path"

if [[ "$path" != "$toplevel"/* ]]; then
  echo "blame-ignore: $path is outside the repository; appended without committing" >&2
  exit 0
fi

short_sha=$(git rev-parse --short "$sha")

git add -- "$path"
git commit -m "$(jira_prefix)Exclude $short_sha from annotations" -- "$path"
