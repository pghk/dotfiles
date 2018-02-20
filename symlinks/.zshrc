#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Use a powerline font
POWERLEVEL9K_MODE='nerdfont-complete'

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...

# Don't add username to prompt if it's me
DEFAULT_USER="paul.hendrick"

# Better searching in command mode
bindkey -M vicmd '?' history-incremental-search-backward
bindkey -M vicmd '/' history-incremental-search-forward

# Beginning search with arrow keys
bindkey "^[OA" up-line-or-search
bindkey "^[OB" down-line-or-search
bindkey -M vicmd "k" up-line-or-search
bindkey -M vicmd "j" down-line-or-search

# Make Vi mode transitions faster (KEYTIMEOUT is in hundredths of a second)
export KEYTIMEOUT=1

## POWERLEVEL9K SETTINGS ##
POWERLEVEL9K_STATUS_VERBOSE=false
POWERLEVEL9K_STATUS_OK_IN_NON_VERBOSE=true
POWERLINE_BASH_CONTINUATION=1
POWERLINE_BASH_SELECT=1
# POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vi_mode dir)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(root_indicator rbenv vcs status)
POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
POWERLEVEL9K_VCS_HIDE_TAGS=true

POWERLEVEL9K_SHORTEN_DIR_LENGTH=4
# POWERLEVEL9K_SHORTEN_STRATEGY=truncate_from_right
POWERLEVEL9K_HOME_ICON=''
POWERLEVEL9K_HOME_SUB_ICON=''
POWERLEVEL9K_FOLDER_ICON=''

POWERLEVEL9K_VI_INSERT_MODE_STRING="\uf105"
POWERLEVEL9K_VI_COMMAND_MODE_STRING="\ue234"
POWERLEVEL9K_VI_MODE_INSERT_BACKGROUND='black'
POWERLEVEL9K_VI_MODE_INSERT_FOREGROUND='green'
POWERLEVEL9K_VI_MODE_NORMAL_BACKGROUND='black'
POWERLEVEL9K_VI_MODE_NORMAL_FOREGROUND='red'

#POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=""
#POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="%F{green}\uf460%f "

POWERLEVEL9K_TIME_BACKGROUND="black"
POWERLEVEL9K_TIME_FOREGROUND="white"

POWERLEVEL9K_VCS_CLEAN_BACKGROUND="black"
POWERLEVEL9K_VCS_CLEAN_FOREGROUND="blue"
POWERLEVEL9K_VCS_MODIFIED_BACKGROUND="black"
POWERLEVEL9K_VCS_MODIFIED_FOREGROUND="green"
POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND="black"
POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND="magenta"
