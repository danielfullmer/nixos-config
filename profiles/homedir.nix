{ config, pkgs, lib, ... }:
{
  # This is a hack
  system.activationScripts = {
    dotfiles = lib.stringAfter [ "users" ]
    ''
      cd /home/danielrf
      ln -fs ${../dotfiles}/.Xmodmap
      ln -fs ${../dotfiles}/.Xresources
      ln -fs ${../dotfiles}/.aliases
      ln -fns ${../dotfiles}/.base16-shell
      ln -fns ${../dotfiles}/.base16-xresources
      ln -fs ${../dotfiles}/.bashrc
      mkdir -p .config/{bspwm,fish,gtk-3.0,matplotlib,sxhkd,termite,panel}
      chown danielrf:danielrf .config .config/{bspwm,fish,gtk-3.0,matplotlib,sxhkd,termite,panel}
      ln -fs ${../dotfiles}/.config/bspwm/bspwmrc .config/bspwm/bspwmrc
      ln -fs ${../dotfiles}/.config/fish/config.fish .config/fish/config.fish
      ln -fs ${../dotfiles}/.config/gtk-3.0/settings.ini .config/gtk-3.0/settings.ini
      ln -fs ${../dotfiles}/.config/matplotlib/matplotlibrc .config/matplotlib/matplotlibrc
      ln -fs ${../dotfiles}/.config/sxhkd/sxhkdrc .config/sxhkd/sxhkdrc
      ln -fs ${../dotfiles}/.config/termite/config .config/termite/config
      ln -fs ${../dotfiles}/.config/panel/conkyrc .config/panel/conkyrc
      ln -fs ${../dotfiles}/.config/panel/panel .config/panel/panel
      ln -fs ${../dotfiles}/.config/panel/panel_bar .config/panel/panel_bar
      ln -fs ${../dotfiles}/.config/panel/panel_colors .config/panel/panel_colors
      mkdir -p .fonts
      ln -fs ${../dotfiles}/.gitconfig
      mkdir -p .gnupg
      chown danielrf:danielrf .gnupg
      ln -fs ${../dotfiles}/.gnupg/gpg-agent.conf .gnupg/gpg-agent.conf
      ln -fs ${../dotfiles}/.gtkrc-2.0
      ln -fs ${../dotfiles}/.gvimrc
      ln -fs ${../dotfiles}/.latexmkrc
      mkdir -p .local/bin
      chown danielrf:danielrf .local .local/bin
      ln -fs ${../dotfiles}/.local/bin/yank .local/bin/yank
      ln -fs ${../dotfiles}/.local/bin/git-latexdiff .local/bin/git-latexdiff
      ln -fs ${../dotfiles}/.local/bin/rofi-pdf .local/bin/rofi-pdf
      ln -fs ${../dotfiles}/.screenrc
      ln -fs ${../dotfiles}/.taskrc
      ln -fs ${../dotfiles}/.tmux.conf
      ln -fs ${../dotfiles}/.tmux.line
      mkdir -p .vim/{autoload,ftdetect,indent,syntax}
      chown danielrf:danielrf .vim .vim/{autoload,ftdetect,indent,syntax}
      ln -fs ${../dotfiles}/.vim/autoload/plug.vim .vim/autoload/plug.vim
      ln -fs ${../dotfiles}/.vim/ftdetect/proto.vim .vim/ftdetect/proto.vim
      ln -fs ${../dotfiles}/.vim/indent/python.vim .vim/indent/python.vim
      ln -fs ${../dotfiles}/.vim/syntax/proto.vim .vim/syntax/proto.vim
      ln -fs ${../dotfiles}/.vimrc
      ln -fs ${../dotfiles}/.xinitrc
      ln -fs ${../dotfiles}/.xmobarrc
      mkdir -p .xmonad
      chown danielrf:danielrf .xmonad
      ln -fs ${../dotfiles}/.xmonad/xmonad.hs .xmonad/xmonad.hs
      ln -fs ${../dotfiles}/.xsettingsd
      ln -fs ${../dotfiles}/.zshenv
      ln -fs ${../dotfiles}/.zshrc
      ln -fs ${../dotfiles}/.zshrc.prompt
      ln -fns ${../dotfiles}/.zsh-autosuggestions
      ln -fns ${../dotfiles}/.zsh-completions
      ln -fns ${../dotfiles}/.zsh-syntax-highlighting
    '';
  };
}
