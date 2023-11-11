#!/usr/bin/env bats

TEST_BREW_PREFIX="$(brew --prefix)"
load "${TEST_BREW_PREFIX}/lib/bats-support/load.bash"
load "${TEST_BREW_PREFIX}/lib/bats-assert/load.bash"

@test "Prezto is available" {
    run type zprezto-update
    assert_output --regexp 'function'
}
@test "Prezto is configured" {
    . $HOME/.config/zsh/.zshenv
    run echo $XDG_CONFIG_HOME
    assert_output --regexp '^\/Users\/[[:alpha:]]+\/.config$'
}
@test "Command History database installed" {
    run type histdb
    assert_output --regexp 'function'
}
@test "Vim is customized" {
    n=$(ls $HOME/.vim/pack/default/start | wc -l)
    assert [ $n -gt 0 ]
}
