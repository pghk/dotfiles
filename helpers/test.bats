#!/usr/bin/env bats

@test "Basic git configuration set" {
    git config core.excludesfile
}
@test "Custom iTerm configuration set" {
    [[ $(defaults read com.googlecode.iterm2 PrefsCustomFolder) == ~/.iterm ]]
}
@test "Initial defaults logged" {
	local LOG_PATH=$(find "$HOME" -maxdepth 1 -type d -name "${LOG_DIR_PRE}*")
	[ ! -z "$LOG_PATH" ]
    [[ -f "$LOG_PATH/initial.defaults" ]]
    local UPDATED_LOG=$(find "$LOG_PATH" -maxdepth 1 -type f -name $(date +"%F").*.defaults)
    [[ -f "$UPDATED_LOG" ]]
}
@test "Mackup is available" {
    command -v mackup
}
@test "Terminus is available" {
    command -v terminus
}