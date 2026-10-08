#!/usr/bin/env bash
# git-pint — format changed PHP files with Laravel Pint, leaving the changes uncommitted
# Usage:
#   git pint [<base>] [--test | --diff] [-- <file>...]
#
# Files: PHP files changed in merge-base(<base>, HEAD)..HEAD, or the files after `--`.
# <base> defaults to origin/HEAD.
# Files with staged or unstaged edits are skipped.
#
#   (default)        format; print the changed files on stdout (commit them with git commit-format)
#   --test           report files needing formatting; change nothing
#   --diff           show the diff Pint would make; change nothing
#
# Exit: 0 clean or done, 1 files need formatting (--test), 2 error (parse errors, bad base), 3 Pint not installed.

set -euo pipefail

mode=format
explicit=0
base=""
files=()

while (($#)); do
  case "$1" in
    --test) mode=test ;;
    --diff) mode=diff ;;
    --)
      shift
      explicit=1
      files=("$@")
      break
      ;;
    -*)
      echo "pint: unknown option $1" >&2
      exit 2
      ;;
    *) base="$1" ;;
  esac
  shift
done

toplevel=$(git rev-parse --show-toplevel)
cd "$toplevel"

PINT_BIN="${COMPOSER_HOME:-$HOME/.config/composer}/vendor/bin/pint"
if [[ ! -x "$PINT_BIN" ]]; then
  PINT_BIN="$toplevel/vendor/bin/pint"
fi
if [[ ! -x "$PINT_BIN" ]]; then
  echo "pint: not installed" >&2
  exit 3
fi

if ((explicit == 0)); then
  if [[ -z "$base" ]]; then
    if ! base=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD); then
      echo "pint: no base: pass one, or run 'git remote set-head origin -a'" >&2
      exit 2
    fi
  fi
  if ! git rev-parse --verify --quiet "$base^{commit}" >/dev/null; then
    echo "pint: unknown base '$base'" >&2
    exit 2
  fi
  while IFS= read -r -d '' f; do
    files+=("$f")
  done < <(git diff --name-only -z --diff-filter=ACMR "$base...HEAD" -- '*.php')
fi

dirty=$({ git diff --name-only -z --; git diff --cached --name-only -z --; } | tr '\0' '\n')

targets=()
if ((${#files[@]})); then
  for f in "${files[@]}"; do
    [[ -f "$f" ]] || continue
    if grep -Fxq -- "$f" <<<"$dirty"; then
      echo "pint: skipping $f (has uncommitted changes)" >&2
      continue
    fi
    targets+=("$f")
  done
fi

if ((${#targets[@]} == 0)); then
  echo "pint: no PHP files to check" >&2
  exit 0
fi

pint_args=(--format=json)
[[ "$mode" == test ]] && pint_args+=(--test)

# Targets were clean, so restoring them undoes a partial run.
trap 'git checkout -q -- "${targets[@]}"; exit 130' INT TERM

set +e
out=$("$PINT_BIN" "${pint_args[@]}" "${targets[@]}" 2>/dev/null)
pint_status=$?
set -e

if [[ -z "$out" && $pint_status -ne 0 ]]; then
  echo "pint: failed with exit $pint_status and no output" >&2
  exit 2
fi

errors=$(jq -r '(.errors // [])[] | "  \(.path): \(.message)"' <<<"$out" 2>/dev/null || true)
summary=$(jq -r '(.files // [])[] | "- \(.path // .name): \(.fixers | join(", "))"' <<<"$out" 2>/dev/null || true)

if [[ -n "$errors" ]]; then
  echo "pint: errors:" >&2
  echo "$errors" >&2
  if [[ "$mode" != test ]]; then
    git checkout -q -- "${targets[@]}"
  fi
  exit 2
fi

if [[ "$mode" == test ]]; then
  if [[ -z "$summary" ]]; then
    echo "pint: ${#targets[@]} files checked, clean" >&2
    exit 0
  fi
  echo "pint: files needing formatting:" >&2
  echo "$summary" >&2
  exit 1
fi

changed=()
while IFS= read -r -d '' f; do
  changed+=("$f")
done < <(git diff --name-only -z -- "${targets[@]}")

if ((${#changed[@]} == 0)); then
  echo "pint: ${#targets[@]} files checked, clean" >&2
  exit 0
fi

if [[ "$mode" == diff ]]; then
  git --no-pager diff -- "${changed[@]}"
  git checkout -q -- "${changed[@]}"
  exit 0
fi

trap - INT TERM
echo "pint: formatted ${#changed[@]} files (uncommitted); run 'git commit-format'" >&2
printf '%s\n' "${changed[@]}"
