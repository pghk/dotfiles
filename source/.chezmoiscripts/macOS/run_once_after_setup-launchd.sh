#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail -o xtrace

SOURCE="${HOME}/.local/share/chezmoi/assets"
TARGET=~/Library/LaunchAgents

AGENTS=(
  "com.1password.SSH_AUTH_SOCK.plist"
)

mkdir -p $TARGET
for AGENT in ${AGENTS[*]}; do
  cp "$SOURCE/${AGENT}" "${TARGET}/${AGENT}"
  sed -i '' "s/USER/$USER/g" "${TARGET}/${AGENT}"
  GUI="gui/$(id -u "$USER")"
  launchctl bootout "${GUI}/${AGENT%.plist}" 2>/dev/null || true
  launchctl bootstrap "${GUI}" "${TARGET}/${AGENT}"
done
