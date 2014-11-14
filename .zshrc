# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

if [[ "$TERM" == "xterm" && "$COLORTERM" == "gnome-terminal" ]]; then
	export TERM=xterm-256color
fi

source "${HOME}/.base16-shell/base16-monokai.dark.sh"
source "${HOME}/.zshrc.prompt"

# Extra aliases
source "${HOME}/.aliases"
