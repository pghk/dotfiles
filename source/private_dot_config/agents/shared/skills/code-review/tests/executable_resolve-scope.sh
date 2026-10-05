#!/usr/bin/env bash

set -euo pipefail

skill_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
resolver="$skill_dir/scripts/resolve-scope.sh"
temporary_directory=$(mktemp -d)
test_count=0

cleanup() {
    rm -rf "$temporary_directory"
}

trap cleanup EXIT

fail() {
    printf 'not ok %d - %s\n' "$test_count" "$1" >&2
    exit 1
}

assert_contains() {
    local output=$1
    local expected=$2

    [[ "$output" == *"$expected"* ]] || fail "expected output to contain: $expected"
}

assert_not_contains() {
    local output=$1
    local unexpected=$2

    [[ "$output" != *"$unexpected"* ]] || fail "expected output not to contain: $unexpected"
}

new_repository() {
    local name=$1
    local repository="$temporary_directory/$name"

    git init -q -b main "$repository"
    git -C "$repository" config user.name 'Scope Resolver Test'
    git -C "$repository" config user.email 'scope-resolver@example.com'
    printf 'initial %s\n' "$name" > "$repository/history.txt"
    git -C "$repository" add history.txt
    git -C "$repository" commit -qm 'Initial commit'
    printf '%s\n' "$repository"
}

commit_change() {
    local repository=$1
    local message=$2

    printf '%s\n' "$message" >> "$repository/history.txt"
    git -C "$repository" add history.txt
    git -C "$repository" commit -qm "$message"
}

run_test() {
    local name=$1
    shift

    test_count=$((test_count + 1))
    "$@"
    printf 'ok %d - %s\n' "$test_count" "$name"
}

test_lists_base_candidates_without_selecting_one() {
    local repository
    local repository_root
    local output

    repository=$(new_repository candidates)
    repository_root=$(git -C "$repository" rev-parse --show-toplevel)
    git -C "$repository" branch develop
    git -C "$repository" switch -qc feature
    commit_change "$repository" 'Feature one'

    output=$("$resolver" "$repository" --no-fetch candidates feature)

    assert_contains "$output" $'REPOSITORY_PATH\t'"$repository_root"
    assert_contains "$output" $'MODE\tcandidates'
    assert_contains "$output" $'FETCH\tskipped'
    assert_contains "$output" $'SOURCE_REF\tfeature'
    assert_contains "$output" $'CANDIDATE_REF\trefs/heads/develop'
    assert_contains "$output" $'RELATION\ttarget-ancestor-of-source'
    assert_contains "$output" $'HEAD_ONLY_COUNT\t1'
    assert_contains "$output" $'SELECTED_COMMIT_COUNT\t1'
    assert_not_contains "$output" $'SELECTED_BASE\t'
    assert_not_contains "$output" $'MERGE_BASE\t'
}

test_reports_diverged_review_as_three_dot_diff() {
    local repository
    local target
    local source
    local output

    repository=$(new_repository diverged)
    git -C "$repository" branch develop
    git -C "$repository" switch -qc feature
    commit_change "$repository" 'Feature one'
    git -C "$repository" switch -q develop
    commit_change "$repository" 'Develop one'
    target=$(git -C "$repository" rev-parse develop)
    source=$(git -C "$repository" rev-parse feature)

    output=$("$resolver" "$repository" --no-fetch review develop feature)

    assert_contains "$output" $'MODE\treview'
    assert_contains "$output" $'TARGET_REF\tdevelop'
    assert_contains "$output" $'SOURCE_REF\tfeature'
    assert_contains "$output" $'GIT_VERSION\tgit version '
    assert_contains "$output" $'DIFF_SPEC\t'"${target}...${source}"
    assert_contains "$output" $'RELATION\tdiverged'
    assert_contains "$output" $'TARGET_ONLY_COUNT\t1'
    assert_contains "$output" $'SOURCE_ONLY_COUNT\t1'
    assert_contains "$output" $'SELECTED_COMMIT_COUNT\t1'
    assert_contains "$output" $'INSPECTION\tthree-dot'
    assert_not_contains "$output" $'MERGE_BASE\t'
    assert_not_contains "$output" $'PARENT_PATCH_COUNT\t'
}

test_reports_three_dot_review_with_multiple_merge_bases() {
    local repository
    local left_commit
    local right_commit
    local target
    local source
    local output

    repository=$(new_repository multiple-merge-bases)
    git -C "$repository" branch left
    git -C "$repository" branch right

    git -C "$repository" switch -q left
    commit_change "$repository" 'Left one'
    left_commit=$(git -C "$repository" rev-parse HEAD)

    git -C "$repository" switch -q right
    commit_change "$repository" 'Right one'
    right_commit=$(git -C "$repository" rev-parse HEAD)

    git -C "$repository" switch -q left
    git -C "$repository" merge -q --no-ff -s ours -m 'Merge right into left' "$right_commit"

    git -C "$repository" switch -q right
    git -C "$repository" merge -q --no-ff -s ours -m 'Merge left commit into right' "$left_commit"

    target=$(git -C "$repository" rev-parse left)
    source=$(git -C "$repository" rev-parse right)
    output=$("$resolver" "$repository" --no-fetch review left right)

    assert_contains "$output" $'MODE\treview'
    assert_contains "$output" $'DIFF_SPEC\t'"${target}...${source}"
    assert_contains "$output" $'INSPECTION\tthree-dot'
    assert_not_contains "$output" $'MERGE_BASE\t'
}

test_rejects_empty_review_scope() {
    local repository
    local output
    local status

    repository=$(new_repository empty)
    set +e
    output=$("$resolver" "$repository" --no-fetch review HEAD HEAD 2>&1)
    status=$?
    set -e

    [[ $status -ne 0 ]] || fail 'expected empty scope to fail'
    assert_contains "$output" $'ERROR\tempty-selection'
}

test_rejects_unresolved_option_like_revision() {
    local repository
    local output
    local status

    repository=$(new_repository unresolved)
    set +e
    output=$("$resolver" "$repository" --no-fetch candidates '--all' 2>&1)
    status=$?
    set -e

    [[ $status -ne 0 ]] || fail 'expected unresolved revision to fail'
    assert_contains "$output" $'ERROR\tunresolved-revision\t--all'
    assert_not_contains "$output" 'usage:'
}

test_rejects_unrelated_review_history() {
    local repository
    local unrelated_repository
    local unrelated_commit
    local output
    local status

    repository=$(new_repository related)
    unrelated_repository=$(new_repository unrelated-source)
    unrelated_commit=$(git -C "$unrelated_repository" rev-parse HEAD)
    git -C "$repository" fetch -q "$unrelated_repository" "$unrelated_commit"

    set +e
    output=$("$resolver" "$repository" --no-fetch review HEAD "$unrelated_commit" 2>&1)
    status=$?
    set -e

    [[ $status -ne 0 ]] || fail 'expected unrelated history to fail'
    assert_contains "$output" $'ERROR\tunrelated-histories'
}

test_fetches_before_resolving_remote_head() {
    local source_repository
    local remote_repository="$temporary_directory/fetch-remote.git"
    local review_repository="$temporary_directory/fetch-review"
    local output

    source_repository=$(new_repository fetch-source)
    git -C "$source_repository" branch develop
    git init -q --bare "$remote_repository"
    git -C "$source_repository" remote add origin "$remote_repository"
    git -C "$source_repository" push -q origin main develop
    git -C "$remote_repository" symbolic-ref HEAD refs/heads/main
    git clone -q "$remote_repository" "$review_repository"
    git -C "$review_repository" config user.name 'Scope Resolver Test'
    git -C "$review_repository" config user.email 'scope-resolver@example.com'

    git -C "$source_repository" switch -qc feature
    commit_change "$source_repository" 'Remote feature'
    git -C "$source_repository" push -q origin feature

    output=$("$resolver" "$review_repository" candidates origin/feature)

    assert_contains "$output" $'FETCH\tperformed'
    assert_contains "$output" $'SOURCE_REF\torigin/feature'
    assert_contains "$output" $'CANDIDATE_REF\trefs/remotes/origin/develop'
    assert_contains "$output" $'HEAD_ONLY_COUNT\t1'
}

test_stops_when_fetch_fails() {
    local repository
    local output
    local status

    repository=$(new_repository fetch-failure)
    git -C "$repository" branch develop
    git -C "$repository" remote add broken "$temporary_directory/does-not-exist.git"

    set +e
    output=$("$resolver" "$repository" candidates HEAD 2>&1)
    status=$?
    set -e

    [[ $status -ne 0 ]] || fail 'expected fetch failure to stop resolution'
    assert_contains "$output" $'ERROR\tfetch-failed'
    assert_not_contains "$output" $'SOURCE_OID\t'
}

test_rejects_shallow_repository() {
    local source_repository
    local shallow_repository="$temporary_directory/shallow-review"
    local output
    local status

    source_repository=$(new_repository shallow-source)
    git -C "$source_repository" branch develop
    git -C "$source_repository" switch -qc feature
    commit_change "$source_repository" 'Shallow feature'
    git clone -q --depth 1 --branch feature "file://$source_repository" "$shallow_repository"

    set +e
    output=$("$resolver" "$shallow_repository" --no-fetch candidates HEAD 2>&1)
    status=$?
    set -e

    [[ $status -ne 0 ]] || fail 'expected a shallow repository to fail'
    assert_contains "$output" $'ERROR\tshallow-repository'
}

test_lists_candidates_from_every_configured_remote() {
    local source_repository
    local remote_repository="$temporary_directory/multiple-remotes.git"
    local review_repository="$temporary_directory/multiple-remotes-review"
    local output

    source_repository=$(new_repository multiple-remotes-source)
    git -C "$source_repository" branch develop
    git -C "$source_repository" branch master
    git init -q --bare "$remote_repository"
    git -C "$source_repository" remote add origin "$remote_repository"
    git -C "$source_repository" push -q origin main develop master
    git -C "$remote_repository" symbolic-ref HEAD refs/heads/main
    git clone -q "$remote_repository" "$review_repository"
    git -C "$review_repository" remote add upstream "$remote_repository"

    output=$("$resolver" "$review_repository" candidates HEAD)

    assert_contains "$output" $'CANDIDATE_REF\trefs/remotes/origin/develop'
    assert_contains "$output" $'CANDIDATE_REF\trefs/remotes/origin/master'
    assert_contains "$output" $'CANDIDATE_REF\trefs/remotes/upstream/develop'
    assert_contains "$output" $'CANDIDATE_REF\trefs/remotes/upstream/master'
}

test_rejects_repository_without_base_candidates() {
    local repository
    local output
    local status

    repository=$(new_repository no-candidates)

    set +e
    output=$("$resolver" "$repository" --no-fetch candidates HEAD 2>&1)
    status=$?
    set -e

    [[ $status -ne 0 ]] || fail 'expected missing candidates to fail'
    assert_contains "$output" $'ERROR\tno-base-candidates'
}

run_test 'lists base candidates without selecting one' test_lists_base_candidates_without_selecting_one
run_test 'reports diverged review as three-dot diff' test_reports_diverged_review_as_three_dot_diff
run_test 'reports three-dot review with multiple merge bases' test_reports_three_dot_review_with_multiple_merge_bases
run_test 'rejects an empty review scope' test_rejects_empty_review_scope
run_test 'rejects an unresolved option-like revision safely' test_rejects_unresolved_option_like_revision
run_test 'rejects unrelated review history' test_rejects_unrelated_review_history
run_test 'fetches before resolving a remote head' test_fetches_before_resolving_remote_head
run_test 'stops when fetch fails' test_stops_when_fetch_fails
run_test 'rejects a shallow repository' test_rejects_shallow_repository
run_test 'lists candidates from every configured remote' test_lists_candidates_from_every_configured_remote
run_test 'rejects a repository without base candidates' test_rejects_repository_without_base_candidates

printf '1..%d\n' "$test_count"
