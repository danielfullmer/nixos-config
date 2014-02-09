export EDITOR="/usr/bin/vim"
export PYTHONPATH="/usr/local/lib/python2.7/site-packages:$PYTHONPATH"
export PATH="$HOME/.local/bin:$HOME/.cabal/bin:$PATH"

# Customize to your needs...
path=(
    $HOME/.local/bin
    /home/danielrf/.cabal/bin
    /usr/local/bin
    /usr/local/sbin
    $path
)

if which ruby >/dev/null && which gem >/dev/null; then
    path=(
        $(ruby -rubygems -e 'puts Gem.user_dir')/bin
        $path
    )
fi

[[ -f ~/.profile.local ]] && source ~/.profile.local
