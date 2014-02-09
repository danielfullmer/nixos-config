# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

if [[ "$TERM" == "xterm" && "$COLORTERM" == "gnome-terminal" ]]; then
	export TERM=xterm-256color
fi
