#!/usr/bin/env bats

@test "Shell is zsh" {
    [[ $(echo $SHELL) == "/usr/local/bin/zsh" ]]
}
@test "Basic git configuration exists" {
    git config core.excludesfile
}
@test "Global gitignore is importable" {
    [[ -f $(git config core.excludesfile) ]]
}
@test "Custom iTerm configuration is set" {
    [[ $(defaults read com.googlecode.iterm2 PrefsCustomFolder) == "~/.iterm" ]]
}
@test "Custom emoji font exists" {
    [[ -f "${HOME}/Library/Fonts/Apple Color Emoji.ttc" ]]
}