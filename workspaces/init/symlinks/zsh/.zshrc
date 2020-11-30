#
# Executes commands at the start of an interactive session.
#

# Initialize Zsh configuration framework.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

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

# Store history in a database, with larkery/zsh-histdb
if [[ -s "$HOME/.zsh_plugins/zsh-histdb/sqlite-history.zsh" ]]; then
	HISTDB_TABULATE_CMD=(sed -e $'s/\x1f/\t/g')
	source "$HOME/.zsh_plugins/zsh-histdb/sqlite-history.zsh"
	autoload -Uz add-zsh-hook
	add-zsh-hook precmd histdb-update-outcome
fi

# Suggest most frequently issued (non-zero exiting) command from this || any dir
_zsh_autosuggest_strategy_histdb_top() {
	local query="select commands.argv from
history left join commands on history.command_id = commands.rowid
left join places on history.place_id = places.rowid
where commands.argv LIKE '$(sql_escape $1)%'
and history.exit_status = 0
group by commands.argv
order by places.dir != '$(sql_escape $PWD)', count(*) desc limit 1"
	suggestion=$(_histdb_query "$query")
}
ZSH_AUTOSUGGEST_STRATEGY=(histdb_top)
