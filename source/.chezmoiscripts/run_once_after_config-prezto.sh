#!/usr/bin/env zsh
set -o errexit -o nounset -o pipefail -o xtrace

# Place our patched runcom files downstream of those provided by Prezto,
# using relative symlinks 

Z="${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}"

setopt EXTENDED_GLOB
for theirs in "${Z}"/.zprezto/runcoms/^README.md(.N); do
  ours="${Z}/.${theirs:t}" 
  if [[ -L $ours ]]; then
    continue
  fi
  [[ ! -f $ours ]] || mv -f $ours $theirs
  ln -s ".zprezto/runcoms/${theirs:t}" $ours
done

