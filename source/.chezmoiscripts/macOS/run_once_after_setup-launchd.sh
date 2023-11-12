#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail -o xtrace

DEF="$HOME"/.local/share/chezmoi/assets/auto.prune_downloads.plist
LAUNCH=~/Library/LaunchAgents
AGENT=com."$USER".prune_downloads.plist

mkdir -p $LAUNCH
cp "$DEF" "${LAUNCH}/${AGENT}"
sed -i '' "s/USER/$USER/g" "${LAUNCH}/${AGENT}"
launchctl bootstrap gui/"$(id -u "$USER")" "${LAUNCH}/${AGENT}"
