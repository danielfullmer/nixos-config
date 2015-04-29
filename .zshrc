source "${HOME}/.zgen/zgen.zsh"

if ! zgen saved; then
    echo "Creating a zgen save"

    zgen oh-my-zsh

    zgen oh-my-zsh plugins/git
    zgen oh-my-zsh plugins/ssh-agent
    zgen oh-my-zsh plugins/sudo
    zgen load zsh-users/zsh-syntax-highlighting

    zgen load zsh-users/zsh-completions

    zgen save
fi


if [[ "$TERM" == "xterm" && "$COLORTERM" == "gnome-terminal" ]]; then
	export TERM=xterm-256color
fi

source "${HOME}/.base16-shell/base16-monokai.dark.sh"
source "${HOME}/.zshrc.prompt"

# Extra aliases
source "${HOME}/.aliases"
