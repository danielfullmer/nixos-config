export EDITOR="vim"
export BROWSER="chromium"
export PYTHONPATH="/usr/local/lib/python2.7/site-packages:$PYTHONPATH"
export GOPATH="$HOME/go"
export PATH="$HOME/.local/bin:$HOME/go/bin:$HOME/.cabal/bin:$PATH"

export SSH_AUTH_SOCK="${HOME}/.gnupg/S.gpg-agent.ssh"

eval $(dircolors ${HOME}/.dircolors)

if which ruby >/dev/null && which gem >/dev/null; then
    PATH="$(ruby -rubygems -e 'puts Gem.user_dir')/bin:$PATH"
fi

[[ -f ~/.profile.local ]] && source ~/.profile.local
