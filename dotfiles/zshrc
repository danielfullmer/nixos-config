if [[ "$TERM" == "xterm" && "$COLORTERM" == "gnome-terminal" ]]; then
	export TERM=xterm-256color
fi

export SSH_AUTH_SOCK="${HOME}/.gnupg/S.gpg-agent.ssh"
gpg-connect-agent updatestartuptty /bye >/dev/null 2>/dev/null

bindkey -e # Use emacs keys

fpath=("${HOME}/.zsh-completions/src" $fpath)
autoload -U compinit && compinit
source "${HOME}/.zsh-history-substring-search/zsh-history-substring-search.zsh"
source "${HOME}/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

BASE16_SHELL="${HOME}/.base16-shell/base16-tomorrow.dark.sh"
[[ -s $BASE16_SHELL ]] && . $BASE16_SHELL

source "${HOME}/.profile"
source "${HOME}/.zshrc.prompt"

# Extra aliases
source "${HOME}/.aliases"
