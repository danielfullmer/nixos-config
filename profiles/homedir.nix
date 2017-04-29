{ config, pkgs, lib, ... }:
{
  # This is a hack
  system.activationScripts = {
    dotfiles = lib.stringAfter [ "users" ]
    ''
      cd /home/danielrf
      ln -fs ${../dotfiles}/.gitconfig
      mkdir -p .gnupg
      chown danielrf:danielrf .gnupg
      chmod 700 .gnupg
      ln -fs ${../dotfiles}/.gnupg/gpg-agent.conf .gnupg/gpg-agent.conf
      ln -fs ${../dotfiles}/.latexmkrc
      mkdir -p .local/bin
      chown danielrf:danielrf .local .local/bin
      ln -fs ${../dotfiles}/.local/bin/yank .local/bin/yank
      ln -fs ${../dotfiles}/.local/bin/rofi-pdf .local/bin/rofi-pdf
      ln -fs ${../dotfiles}/.taskrc
      ln -fns /run/current-system/sw/share/terminfo .terminfo  # TODO: See issue #19785
      touch .zshrc
      chown danielrf:danielrf .zshrc
    '';
  };
}
