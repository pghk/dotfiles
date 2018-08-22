#!/usr/bin/env bats

@test "Basic git configuration exists" {
    git config core.excludesfile
}
@test "Custom iTerm configuration is set" {
    [[ $(defaults read com.googlecode.iterm2 PrefsCustomFolder) == "~/.iterm" ]]
}
@test "Custom emoji font exists" {
    [[ -f "${HOME}/Library/Fonts/Apple Color Emoji.ttc" ]]
}
@test "Initial defaults logged" {
    [[ -f "${HOME}/.$(date +"%d-%b").initial.defaults" ]]
}
@test "Defaults customized" {
    run diff ~/.$(date +"%d-%b").initial.defaults ~/.$(date +"%d-%b").custom.defaults
    [ "$status" -eq 1 ]
}
@test "Custom defaults logged" {
    [[ -f "${HOME}/.$(date +"%d-%b").custom.defaults" ]]
}