#!/usr/bin/env zsh
set -o errexit -o nounset -o pipefail -o xtrace

# Link any remaining runcoms that we're not overriding

Z="${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}"
P="${Z}/.zprezto"

setopt EXTENDED_GLOB
for rcfile in "${P}"/runcoms/^README.md(.N); do
 [[ -f "${Z}/.${rcfile:t}" ]] || ln -s "$rcfile" "${Z}/.${rcfile:t}"
done

