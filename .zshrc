source $HOME/.antigen/antigen.zsh

antigen use oh-my-zsh

antigen bundle archlinux
antigen bundle colored-man
antigen bundle git
antigen bundle github
antigen bundle pip
antigen bundle python
antigen bundle systemd
antigen bundle vagrant
antigen bundle virtualenv
antigen bundle zsh-users/zsh-syntax-highlighting

if [[ "$COLORTERM" == "gnome-terminal" ]]; then
	export TERM=xterm-256color
fi

# Customize to your needs...
export PATH=$PATH:/home/danielrf/.gem/ruby/2.0.0/bin:/home/danielrf/.local/bin:/home/danielrf/.cabal/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/usr/bin/core_perl
