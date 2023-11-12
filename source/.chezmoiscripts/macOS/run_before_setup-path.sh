#!/usr/bin/env bash
set -o errexit -o pipefail -o xtrace

has_brew=$(echo $PATH | grep -q brew)
if [ ! has_brew ] && [ -d /opt/homebrew ] && [ -n $ZDOTDIR ]; then
	cat $(/opt/homebrew/bin/brew shellenv) >>$HOME/.zshenv
fi
