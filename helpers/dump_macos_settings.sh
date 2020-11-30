#!/usr/bin/env bash

# Helps with tracking changes in macOS settings,
# by writing the 'defaults' command out to a file.

set -o errexit -o nounset -o pipefail -o xtrace

LOG_DIR_PRE=".sysinstall."
FILE_PRE=$(date +"%F.%H%M%S")
LOG_PATH=$(find "$HOME" -maxdepth 1 -type d -name "${LOG_DIR_PRE}*")

if [ -z "$LOG_PATH" ]; then
  FILE_PRE="initial"
  LOG_PATH=~/"$LOG_DIR_PRE"$(date +"%F.%H%M%S")
  mkdir "$LOG_PATH"
fi

defaults read > "$LOG_PATH"/"$FILE_PRE".defaults
