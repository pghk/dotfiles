#!/usr/bin/env sh

# Helps with tracking changes in macOS settings,
# by writing the 'defaults' command out to a file.

set -o errexit -o nounset -o pipefail -o xtrace

FILE_NAME=${1:-$(date +"%F.%H%M").defaults}
FILE_PATH=${2:-$HOME/.local/share/macos}

[[ -d $FILE_PATH ]] || mkdir -p $FILE_PATH

defaults read >${FILE_PATH}/${FILE_NAME}
