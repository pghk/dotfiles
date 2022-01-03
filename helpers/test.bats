#!/usr/bin/env bats

@test "Basic git configuration set" {
    git config core.excludesfile
}
@test "Custom iTerm configuration set" {
    [[ $(defaults read com.googlecode.iterm2 PrefsCustomFolder) == ~/.iterm ]]
}
@test "Install process logged" {
    local -r LOG_DIR=".setup_logs"
    local -r LOG_PATH=$(find "$HOME" -maxdepth 1 -type d -name "$LOG_DIR")
    [ -n "$LOG_PATH" ]
    local -r INIT_LOG=$LOG_PATH/initial.defaults
    [[ -f "$INIT_LOG" ]]
    local -r UPDATED_LOG=$(find "$LOG_PATH" -maxdepth 1 -type f -name "$(date +"%F").*.defaults")
    [ -n "$UPDATED_LOG" ]
    run diff "$INIT_LOG" "$UPDATED_LOG"
    [ "$status" -eq 1 ]
}
@test "Defaults customized" {
    run defaults read NSGlobalDomain KeyRepeat
    [ "$output" = 2 ]
}
@test "Mackup is available" {
    command -v mackup
}
@test "Terminus is available" {
    command -v terminus
}