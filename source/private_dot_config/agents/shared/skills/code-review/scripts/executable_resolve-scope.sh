#!/usr/bin/env bash

set -euo pipefail

usage() {
    cat >&2 <<'EOF'
Usage:
  resolve-scope.sh <repository> [--no-fetch] candidates [<source>]
  resolve-scope.sh <repository> [--no-fetch] review <target> <source>
EOF
    exit 64
}

error() {
    local status=$1
    shift

    printf 'ERROR\t%s\n' "$*" >&2
    exit "$status"
}

repository_git() {
    git -C "$repository" "$@"
}

resolve_commit() {
    local revision=$1
    local commit

    if ! commit=$(repository_git rev-parse --verify --end-of-options "${revision}^{commit}" 2>/dev/null); then
        error 67 $'unresolved-revision\t'"$revision"
    fi

    printf '%s\n' "$commit"
}

print_fetch_detail() {
    local detail=$1

    while IFS= read -r line; do
        printf 'FETCH_DETAIL\t%s\n' "$line" >&2
    done <<< "$detail"
}

relationship() {
    local target=$1
    local source=$2

    if ! repository_git merge-base "$target" "$source" >/dev/null 2>&1; then
        printf 'unrelated\n'
    elif repository_git merge-base --is-ancestor "$target" "$source"; then
        printf 'target-ancestor-of-source\n'
    elif repository_git merge-base --is-ancestor "$source" "$target"; then
        printf 'source-ancestor-of-target\n'
    else
        printf 'diverged\n'
    fi
}

left_right_counts() {
    local target=$1
    local source=$2

    repository_git rev-list --left-right --count --end-of-options "${target}...${source}"
}

print_review_counts() {
    local target=$1
    local source=$2
    local selected_commits
    local selected_count
    local merge_count
    local non_merge_count
    local commit

    selected_commits=$(repository_git rev-list --topo-order --end-of-options "${target}..${source}")
    if [[ -z "$selected_commits" ]]; then
        error 68 'empty-selection'
    fi

    selected_count=$(wc -l <<< "$selected_commits" | tr -d ' ')
    merge_count=$(repository_git rev-list --count --min-parents=2 --end-of-options "${target}..${source}")
    non_merge_count=$((selected_count - merge_count))

    printf 'SELECTED_COMMIT_COUNT\t%s\n' "$selected_count"
    printf 'MERGE_COMMIT_COUNT\t%s\n' "$merge_count"
    printf 'NON_MERGE_COMMIT_COUNT\t%s\n' "$non_merge_count"
    while IFS= read -r commit; do
        printf 'SELECTED_COMMIT\t%s\n' "$commit"
    done <<< "$selected_commits"
}

print_candidate() {
    local candidate_ref=$1
    local candidate=$2
    local source=$3
    local relation
    local counts
    local target_only
    local source_only

    relation=$(relationship "$candidate" "$source")
    counts=$(left_right_counts "$candidate" "$source")
    read -r target_only source_only <<< "$counts"

    printf 'CANDIDATE_REF\t%s\n' "$candidate_ref"
    printf 'CANDIDATE_TIP\t%s\n' "$candidate"
    printf 'RELATION\t%s\n' "$relation"
    printf 'BASE_ONLY_COUNT\t%s\n' "$target_only"
    printf 'HEAD_ONLY_COUNT\t%s\n' "$source_only"
    printf 'SELECTED_COMMIT_COUNT\t%s\n' "$source_only"
    printf '\n'
}

list_candidate_refs() {
    local candidate_ref
    local remote
    local trunk

    for trunk in develop master; do
        candidate_ref="refs/heads/$trunk"
        if repository_git show-ref --verify --quiet "$candidate_ref"; then
            printf '%s\n' "$candidate_ref"
        fi
    done

    while IFS= read -r remote; do
        [[ -n "$remote" ]] || continue
        for trunk in develop master; do
            candidate_ref="refs/remotes/$remote/$trunk"
            if repository_git show-ref --verify --quiet "$candidate_ref"; then
                printf '%s\n' "$candidate_ref"
            fi
        done
    done < <(repository_git remote)
}

resolve_candidates() {
    local source_ref=${1:-HEAD}
    local source
    local candidate_refs
    local candidate_ref
    local candidate

    source=$(resolve_commit "$source_ref")
    printf 'MODE\tcandidates\n'
    printf 'SOURCE_REF\t%s\n' "$source_ref"
    printf 'SOURCE_OID\t%s\n' "$source"

    candidate_refs=$(list_candidate_refs)
    if [[ -z "$candidate_refs" ]]; then
        error 71 'no-base-candidates'
    fi

    while IFS= read -r candidate_ref; do
        candidate=$(resolve_commit "$candidate_ref")
        print_candidate "$candidate_ref" "$candidate" "$source"
    done <<< "$candidate_refs"
}

resolve_review() {
    local target_ref=${1:-}
    local source_ref=${2:-}
    local target
    local source
    local relation
    local counts
    local target_only
    local source_only

    [[ -n "$target_ref" && -n "$source_ref" && $# -eq 2 ]] || usage
    target=$(resolve_commit "$target_ref")
    source=$(resolve_commit "$source_ref")
    relation=$(relationship "$target" "$source")

    if [[ $relation == unrelated ]]; then
        error 70 'unrelated-histories'
    fi

    counts=$(left_right_counts "$target" "$source")
    read -r target_only source_only <<< "$counts"

    printf 'MODE\treview\n'
    printf 'TARGET_REF\t%s\n' "$target_ref"
    printf 'TARGET_OID\t%s\n' "$target"
    printf 'SOURCE_REF\t%s\n' "$source_ref"
    printf 'SOURCE_OID\t%s\n' "$source"
    printf 'GIT_VERSION\t%s\n' "$(repository_git --version)"
    printf 'DIFF_SPEC\t%s...%s\n' "$target" "$source"
    printf 'RELATION\t%s\n' "$relation"
    printf 'TARGET_ONLY_COUNT\t%s\n' "$target_only"
    printf 'SOURCE_ONLY_COUNT\t%s\n' "$source_only"
    print_review_counts "$target" "$source"
    printf 'INSPECTION\tthree-dot\n'
}

repository_input=${1:-}
[[ -n "$repository_input" ]] || usage
shift

if ! repository=$(git -C "$repository_input" rev-parse --show-toplevel 2>/dev/null); then
    error 66 $'not-a-git-repository\t'"$repository_input"
fi

fetch=true
if [[ ${1:-} == --no-fetch ]]; then
    fetch=false
    shift
fi

mode=${1:-}
[[ -n "$mode" ]] || usage
shift

printf 'REPOSITORY_PATH\t%s\n' "$repository"
if $fetch; then
    if ! fetch_detail=$(repository_git fetch --all --prune 2>&1); then
        printf 'ERROR\tfetch-failed\n' >&2
        print_fetch_detail "$fetch_detail"
        exit 69
    fi
    printf 'FETCH\tperformed\n'
else
    printf 'FETCH\tskipped\n'
fi

if [[ $(repository_git rev-parse --is-shallow-repository) == true ]]; then
    error 65 'shallow-repository'
fi

case "$mode" in
    candidates)
        [[ $# -le 1 ]] || usage
        resolve_candidates "$@"
        ;;
    review)
        resolve_review "$@"
        ;;
    *)
        usage
        ;;
esac
