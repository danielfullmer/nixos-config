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
      mkdir -p .config/{fish,gtk-3.0,matplotlib,sxhkd,termite,panel}
      chown danielrf:danielrf .config .config/{fish,gtk-3.0,matplotlib,sxhkd,termite}
      ln -fs ${../dotfiles}/.config/fish/config.fish .config/fish/config.fish
      ln -fs ${../dotfiles}/.config/gtk-3.0/settings.ini .config/gtk-3.0/settings.ini
      ln -fs ${../dotfiles}/.config/matplotlib/matplotlibrc .config/matplotlib/matplotlibrc
      ln -fs ${../dotfiles}/.config/sxhkd/sxhkdrc .config/sxhkd/sxhkdrc
      ln -fs ${../dotfiles}/.config/termite/config .config/termite/config
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
      ln -fs ${../dotfiles}/.xinitrc
      ln -fs ${../dotfiles}/.xmobarrc
      mkdir -p .xmonad
      chown danielrf:danielrf .xmonad
      ln -fs ${../dotfiles}/.xmonad/xmonad.hs .xmonad/xmonad.hs
      ln -fs ${../dotfiles}/.xsettingsd
    '';
  };
}
