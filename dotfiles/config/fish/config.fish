switch (echo $COLORTERM)
    case gnome-terminal
        set -x TERM xterm-256color
end

if status --is-login
    set EDITOR vim
    set PATH $HOME/.local/bin $HOME/.cabal/bin $PATH
end
