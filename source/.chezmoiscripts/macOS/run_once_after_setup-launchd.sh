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
  launchctl bootstrap gui/"$(id -u "$USER")" "${TARGET}/${AGENT}"
done
