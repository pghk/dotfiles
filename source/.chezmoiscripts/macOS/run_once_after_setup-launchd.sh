#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail -o xtrace

DEF="$HOME"/.local/share/chezmoi/assets/auto.prune_downloads.plist
LAUNCH_AGENT=~/Library/LaunchAgents/com."$USER".prune_downloads.plist

cp "$DEF" "$LAUNCH_AGENT"
sed -i '' "s/USER/$USER/g" "$LAUNCH_AGENT"
launchctl bootstrap gui/"$(id -u "$USER")" "$LAUNCH_AGENT"
