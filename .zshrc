HISTFILE=~/.histfile
HISTSIZE=5000
SAVEHIST=5000

[[ -f ${HOME}/.aliases ]] && source $HOME/.aliases

bindkey -e
zstyle :compinstall filename '$HOME.zshrc'

autoload -Uz compinit
compinit

autoload -U promptinit
promptinit
prompt suse

# SCREEN CAPTION/HARDSTATUS
case ${TERM} in
	xterm*|rxvt*|Eterm|aterm|kterm|gnome*|interix)
		precmd () {
                    echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\007"
                }
		preexec () {
                    echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~} $1\007"
                }
		;;
	screen*)
		precmd () {
                    echo -ne "\033k${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\033\\"
                }
                preexec () {
                    echo -ne "\033k${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~} $1\033\\"
                }
		;;
esac

# TERM env variable
if [[ "$COLORTERM" == "gnome-terminal" ]]; then
	export TERM=xterm-256color
fi

[[ -f "${HOME}/.zshrc.local" ]] && source "${HOME}/.zshrc.local"
