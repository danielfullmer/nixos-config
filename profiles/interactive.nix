# interactive.nix: Intended for hosts that I would at least SSH into.

{ config, pkgs, lib, ... }:
{
  users.users.danielrf.shell = "/run/current-system/sw/bin/zsh";

  environment.systemPackages = (with pkgs; [
    binutils
    pciutils
    usbutils
    psmisc
    htop
    ncdu
    bmon
    wget
    cachix

    zerotierone

    tmux
    silver-searcher
    ripgrep
    fzf
    git
    gitAndTools.hub
    neovim
  ]);

  environment.variables = {
    EDITOR = "vim";

    # See also: https://github.com/junegunn/fzf/wiki/Configuring-shell-key-bindings
    FZF_TMUX = "1";
    #FZF_CTRL_T_OPTS="--preview '(${pkgs.highlight}/bin/highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'";
    #FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'";
    #FZF_ALT_C_OPTS="--preview '${pkgs.tree}/bin/tree -C {} | head -200'";
  };

  programs.bash = {
    enableCompletion = true;
    interactiveShellInit = ''
      source ${pkgs.fzf}/share/fzf/completion.bash # Activated with **<TAB>
      source ${pkgs.fzf}/share/fzf/key-bindings.bash # CTRL-R, CTRL-T, and ALT-C
    '';
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting = {
      enable = true;
      highlighters = [ "main" "brackets" ];
    };
    autosuggestions.enable = true;
    promptInit = "source ${../pkgs/zsh/zshrc.prompt}";
    interactiveShellInit = ''
      source ${pkgs.fzf}/share/fzf/completion.zsh # Activated with **<TAB>
      source ${pkgs.fzf}/share/fzf/key-bindings.zsh # CTRL-R, CTRL-T, and ALT-C
    '' + import (../modules/theme/templates + "/shell.${config.theme.brightness}.nix") { colors=config.theme.colors; };
  };

  programs.command-not-found.enable = true;

  environment.etc."tmux.conf".text = import ../pkgs/tmux/tmux.conf.nix { inherit pkgs; };

  environment.interactiveShellInit = ''
    eval $(${pkgs.coreutils}/bin/dircolors "${./dircolors}")
  '';

  environment.extraInit = ''
    export PATH="$HOME/.local/bin:$PATH"
  '';

  environment.shellAliases = {
    ls = "ls --color";
    vi = "vim";
    nfo="iconv -f IBM775";
    t = "task";
    git = "hub";
  };

  # This is a hack
  system.activationScripts = {
    dotfiles = lib.stringAfter [ "users" ]
    ''
      cd /home/danielrf
      ln -fs ${../dotfiles}/.gitconfig
      mkdir -p .gnupg
      chown danielrf:danielrf .gnupg
      chmod 700 .gnupg
      ln -fs ${../dotfiles}/.latexmkrc
      mkdir -p .local/bin
      chown danielrf:danielrf .local .local/bin
      ln -fs ${../dotfiles}/.local/bin/yank .local/bin/yank
      ln -fs ${../dotfiles}/.local/bin/rofi-pdf .local/bin/rofi-pdf
      ln -fs ${../dotfiles}/.taskrc
      touch .zshrc
      chown danielrf:danielrf .zshrc
    '';
  };
}
