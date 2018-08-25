#!/usr/bin/env bats

@test "Basic git configuration set" {
    git config core.excludesfile
}
@test "Custom iTerm configuration set" {
    [[ $(defaults read com.googlecode.iterm2 PrefsCustomFolder) == "~/.iterm" ]]
}
@test "Custom emoji font installed" {
    [[ -f "${HOME}/Library/Fonts/Apple Color Emoji.ttc" ]]
}
@test "Install process logged" {
    [[ -f "${HOME}/.sysinstall.$(date +"%d-%b")/bootstrap.log" ]]
    [[ -f "${HOME}/.sysinstall.$(date +"%d-%b")/shell_setup.log" ]]
}
@test "Defaults customized" {
    run diff ~/.sysinstall.$(date +"%d-%b")/initial.defaults ~/.sysinstall.$(date +"%d-%b")/custom.defaults
    [ "$status" -eq 1 ]
}
