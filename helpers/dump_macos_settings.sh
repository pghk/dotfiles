#!/usr/bin/env bash

# Helps with tracking changes in macOS settings,
# by writing the 'defaults' command out to a file.

set -o errexit -o nounset -o pipefail -o xtrace

LOG_DIR=".setup_logs"

EXISTING_LOG_PATH=$(find "$HOME" -maxdepth 1 -type d -name "$LOG_DIR")
FILE_PRE=${1:-$(date +"%F.%H%M%S")}

if [ -z "$EXISTING_LOG_PATH" ]; then
  FILE_PRE="initial"
  mkdir ~/$LOG_DIR
fi

defaults read > ~/$LOG_DIR/"$FILE_PRE".defaults
