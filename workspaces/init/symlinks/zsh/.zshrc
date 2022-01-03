#
# Executes commands at the start of an interactive session.
#

# Initialize Zsh configuration framework.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Make Vi mode transitions faster (KEYTIMEOUT is in hundredths of a second)
export KEYTIMEOUT=1

# Store history in a database, with larkery/zsh-histdb
if [[ -s "$HOME/.zsh_plugins/zsh-histdb/sqlite-history.zsh" ]]; then
	HISTDB_TABULATE_CMD=(sed -e $'s/\x1f/\t/g')
	source "$HOME/.zsh_plugins/zsh-histdb/sqlite-history.zsh"
	source "$HOME/.zsh_plugins/zsh-histdb/histdb-interactive.zsh"
	autoload -Uz add-zsh-hook
fi

bindkey "^r" _histdb-isearch

# Suggest most frequently issued (and successful) command from this || any dir
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
ZSH_AUTOSUGGEST_STRATEGY=(histdb_top completion)

ITERM_INTEGRATION="${HOME}/.iterm2_shell_integration.zsh"; [ -f $ITERM_INTEGRATION ] && . $ITERM_INTEGRATION

ADDENDUM="${HOME}/.zshrc_custom"; [ -f $ADDENDUM ] && . $ADDENDUM
