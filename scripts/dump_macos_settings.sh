#!/usr/bin/env sh

# Helps with tracking changes in macOS settings,
# by writing the 'defaults' command out to a file.

set -o errexit -o nounset -o pipefail -o xtrace

FILE_PATH=${1:-$HOME/.local/share/macos}
FILE_NAME=${2:-$(date +"%F.%H%M%S").defaults}

[[ -d $FILE_PATH ]] || mkdir -p $FILE_PATH

defaults read >${FILE_PATH}/${FILE_NAME}
