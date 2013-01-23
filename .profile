export EDITOR="/usr/bin/vim"
export PYTHONPATH="/usr/local/lib/python2.7/site-packages:$PYTHONPATH"
export PATH="$HOME/.local/bin:$HOME/.cabal/bin:$PATH"

if which ruby >/dev/null && which gem >/dev/null; then
    export PATH="$(ruby -rubygems -e 'puts Gem.user_dir')/bin:$PATH"
fi

[[ -f ~/.profile.local ]] && source ~/.profile.local
