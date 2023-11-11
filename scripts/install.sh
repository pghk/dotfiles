#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail -o xtrace

MY_USER=pghk

if [ ! command -v brew ] && [ -z $CI ]; then
	"Homebrew installation required: see https://brew.sh/ for instructions"
fi

brew bundle --no-lock --file=/dev/stdin <<-EOF
	brew "chezmoi"
EOF

chezmoi init --verbose --branch next --apply $MY_USER
