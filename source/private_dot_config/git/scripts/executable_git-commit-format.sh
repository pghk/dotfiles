#!/usr/bin/env bash
# git-commit-format — commit uncommitted formatting changes, folding hunks that touch your own
# unpushed lines into the commits that wrote them
# Usage:
#   git commit-format [<base>] [-- <file>...]
#
# Files: the files after `--`, or every file with unstaged changes. The index must be clean.
# <base> defaults to origin/HEAD.
#
# A hunk is "mine" when `git blame` attributes any of its old lines to a commit that is on no
# remote branch (and not in <base>). Each mine hunk becomes a fixup commit for the newest such
# commit and is autosquashed into it. All other hunks go into one commit,
# "<prefix>Format PHP files with Pint", which is then recorded with git blame-ignore.
# If the rebase conflicts, everything goes into that single commit instead.
#
# Prints the SHA of the formatting commit on stdout (nothing if every hunk was folded).
# Exit: 0 done or nothing to do, 2 error.

set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib/jira-prefix.sh
. "$script_dir/lib/jira-prefix.sh"

base=""
explicit=0
files=()

while (($#)); do
  case "$1" in
    --)
      shift
      explicit=1
      files=("$@")
      break
      ;;
    -*)
      echo "commit-format: unknown option $1" >&2
      exit 2
      ;;
    *) base="$1" ;;
  esac
  shift
done

cd "$(git rev-parse --show-toplevel)"

if ! git diff --cached --quiet; then
  echo "commit-format: index has staged changes; commit or unstage them first" >&2
  exit 2
fi

if ((explicit == 0)); then
  while IFS= read -r -d '' f; do
    files+=("$f")
  done < <(git diff --name-only -z)
fi

if ((${#files[@]} == 0)); then
  echo "commit-format: no changes to commit" >&2
  exit 0
fi

if [[ -z "$base" ]]; then
  if ! base=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD); then
    echo "commit-format: no base: pass one, or run 'git remote set-head origin -a'" >&2
    exit 2
  fi
fi
if ! git rev-parse --verify --quiet "$base^{commit}" >/dev/null; then
  echo "commit-format: unknown base '$base'" >&2
  exit 2
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

orig=$(git rev-parse HEAD)
msg="$(jira_prefix)Format PHP files with Pint"

# Unpushed commits, newest first. Folding needs a linear range with a parent below it.
mine=$(git rev-list "$orig" --not --remotes "$base")
fold=1
if [[ -z "$mine" ]] || [[ -n "$(git rev-list --merges "$orig" --not --remotes "$base")" ]]; then
  fold=0
elif ! git rev-parse --verify --quiet "$(tail -n1 <<<"$mine")^" >/dev/null; then
  fold=0
fi

git -c core.quotepath=off diff -U0 --no-color --no-ext-diff --no-renames "$orig" -- "${files[@]}" >"$tmp/full.diff"

awk '
  /^diff --git/ { inh = 0; next }
  !inh && /^\+\+\+ / { file = substr($0, 7); next }
  /^@@ / {
    inh = 1; hid++
    s = $0; sub(/^@@ -/, "", s); split(s, a, " "); split(a[1], o, ",")
    print hid "\t" file "\t" o[1] "\t" (o[2] == "" ? 1 : o[2])
  }
' "$tmp/full.diff" >"$tmp/hunks.tsv"

: >"$tmp/targets.tsv"
if ((fold)); then
  # git blame fails when the configured ignore-revs file is missing.
  if [[ -n "$(git config --get blame.ignoreRevsFile || true)" ]]; then
    "$script_dir/git-blame-ignore.sh" --init >/dev/null 2>&1
  fi
  while IFS=$'\t' read -r hid file os oc; do
    if ((oc == 0)); then
      ranges=""
      ((os >= 1)) && ranges="$os,$os"
      ranges="$ranges $((os + 1)),$((os + 1))"
    else
      ranges="$os,$((os + oc - 1))"
    fi
    shas=""
    for r in $ranges; do
      shas+=$(git blame --porcelain -L "$r" "$orig" -- "$file" 2>/dev/null |
        awk 'NF >= 3 && length($1) == 40 && $1 ~ /^[0-9a-f]+$/ { print $1 }' || true)
      shas+=$'\n'
    done
    for m in $mine; do
      if grep -Fxq -- "$m" <<<"$shas"; then
        printf '%s\t%s\n' "$hid" "$m" >>"$tmp/targets.tsv"
        break
      fi
    done
  done <"$tmp/hunks.tsv"
fi

# Emits the diff restricted to the hunk ids in $1 (space separated), with new-side line numbers
# recomputed for the subset so it applies to $orig on its own.
subset_patch() {
  awk -v sel=" $1 " '
    /^diff --git/ { inh = 0; hdr = $0 "\n"; shown = 0; delta = 0; next }
    !inh && !/^@@ / { hdr = hdr $0 "\n"; next }
    /^@@ / {
      inh = 1; hid++
      s = $0; sub(/^@@ -/, "", s); split(s, a, " ")
      split(a[1], o, ","); os = o[1] + 0; oc = (o[2] == "" ? 1 : o[2] + 0)
      split(substr(a[2], 2), n, ","); nc = (n[2] == "" ? 1 : n[2] + 0)
      pr = index(sel, " " hid " ") > 0
      if (pr) {
        if (!shown) { printf "%s", hdr; shown = 1 }
        pold = (oc == 0) ? os + 1 : os
        pnew = pold + delta
        ns = (nc == 0) ? pnew - 1 : pnew
        printf "@@ -%d,%d +%d,%d @@\n", os, oc, ns, nc
        delta += nc - oc
      }
      next
    }
    inh && pr { print }
  ' "$tmp/full.diff"
}

total=$(wc -l <"$tmp/hunks.tsv" | tr -d ' ')
folded=$(wc -l <"$tmp/targets.tsv" | tr -d ' ')
targets=$(cut -f2 "$tmp/targets.tsv" | awk '!seen[$0]++')

# Fixups come first: each commit's tree is $orig plus the cumulative set of folded hunks.
sel=""
for t in $targets; do
  sel="$sel $(awk -F'\t' -v t="$t" '$2 == t { printf " %s", $1 }' "$tmp/targets.tsv")"
  git read-tree "$orig"
  subset_patch "$sel" | git apply --cached --unidiff-zero -
  git commit -q -m "fixup! $t"
done

git add -- "${files[@]}"
leftover=0
if ! git diff --cached --quiet; then
  git commit -q -m "$msg"
  leftover=1
fi
pre_tip=$(git rev-parse HEAD)

fallback() {
  git rebase --abort 2>/dev/null || true
  git reset -q --soft "$pre_tip"
  git restore --source="$pre_tip" --staged --worktree -- "${files[@]}"
  git reset -q --soft "$orig"
  git commit -q -m "$msg"
  leftover=1
  folded=0
  echo "commit-format: could not fold ($1); committed all formatting together" >&2
}

if [[ -n "$targets" ]]; then
  oldest=$(tail -n1 <<<"$mine")
  if GIT_SEQUENCE_EDITOR=true git rebase -q -i --autosquash --autostash "$oldest^" >/dev/null 2>&1; then
    if [[ "$(git rev-parse HEAD^{tree})" != "$(git rev-parse "$pre_tip^{tree}")" ]]; then
      fallback "rebase changed the result"
    fi
  else
    fallback "rebase conflicted"
  fi
fi

echo "commit-format: $folded of $total hunks folded into earlier commits" >&2

if ((leftover)); then
  sha=$(git rev-parse HEAD)
  echo "commit-format: formatting commit $(git rev-parse --short "$sha")" >&2
  "$script_dir/git-blame-ignore.sh" "$sha" >&2
  echo "$sha"
fi
