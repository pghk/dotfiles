#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail -o xtrace

LAUNCH_AGENT=~/Library/LaunchAgents/com."$USER".prune_downloads.plist

cp "$HOME"/.dotfiles/helpers/auto.prune_downloads.plist "$LAUNCH_AGENT"
sed -i '' "s/USER/$USER/g" "$LAUNCH_AGENT"
launchctl bootstrap gui/"$(id -u "$USER")" "$LAUNCH_AGENT"
