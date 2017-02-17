{ config, pkgs, lib, ... }:
{
  # This is a hack
  system.activationScripts = {
    dotfiles = lib.stringAfter [ "users" ]
    ''
      cd /home/danielrf
      mkdir -p .config/{matplotlib,sxhkd,panel}
      chown danielrf:danielrf .config .config/{matplotlib,sxhkd}
      ln -fs ${../dotfiles}/.config/matplotlib/matplotlibrc .config/matplotlib/matplotlibrc
      ln -fs ${../dotfiles}/.config/sxhkd/sxhkdrc .config/sxhkd/sxhkdrc
      ln -fs ${../dotfiles}/.gitconfig
      mkdir -p .gnupg
      chown danielrf:danielrf .gnupg
      ln -fs ${../dotfiles}/.gnupg/gpg-agent.conf .gnupg/gpg-agent.conf
      ln -fs ${../dotfiles}/.latexmkrc
      mkdir -p .local/bin
      chown danielrf:danielrf .local .local/bin
      ln -fs ${../dotfiles}/.local/bin/yank .local/bin/yank
      ln -fs ${../dotfiles}/.local/bin/rofi-pdf .local/bin/rofi-pdf
      ln -fs ${../dotfiles}/.screenrc
      ln -fs ${../dotfiles}/.taskrc
      ln -fs ${../dotfiles}/.xmobarrc
      mkdir -p .xmonad
      chown danielrf:danielrf .xmonad
      ln -fs ${../dotfiles}/.xmonad/xmonad.hs .xmonad/xmonad.hs
      ln -fs ${../dotfiles}/.xsettingsd
      touch .zshrc
    '';
  };
}
