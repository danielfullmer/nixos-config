[[ -f /etc/rc.conf ]] && source /etc/rc.conf

export PATH="${HOME}/bin:${PATH}"
export EDITOR="/usr/bin/vim"
export BROWSER="firefox %s &"
export AWT_TOOLKIT="GtkToolkit"
export MBOX="${HOME}/Mail/INBOX"
export MAIL="${HOME}/Mail/INBOX"

[[ -f $HOME/.profile.local ]] && source $HOME/.profile.local
