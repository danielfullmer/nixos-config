# interactive.nix: Intended for hosts that I would at least SSH into.

{ config, pkgs, lib, ... }:
let
  userBin = pkgs.runCommand "user-bin" {} "mkdir -p $out/bin; cp ${./bin}/* $out/bin/";
in
{
  imports =  [
    ./keyboard.nix
  ];

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
    #cachix

    zerotierone

    tmux
    silver-searcher
    ripgrep
    fzf
    git
    gitAndTools.gh
    neovim

    taskwarrior
    timewarrior
    # vit # tasklib failing as of 2020-12-23

    sops

    userBin
  ]);

  environment.variables = {
    EDITOR = "vim";

    # See also: https://github.com/junegunn/fzf/wiki/Configuring-shell-key-bindings
    FZF_TMUX = "1";
    FZF_CTRL_T_OPTS="--preview '(${pkgs.highlight}/bin/highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'";
    FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'";
    FZF_ALT_C_OPTS="--preview '${pkgs.tree}/bin/tree -C {} | head -200'";
  };

  programs.bash = {
    enableCompletion = true;
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
  };

  programs.command-not-found.enable = true;

  environment.etc."tmux.conf".text = config.programs.tmux.config;

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
    tw = "timew";
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
      ln -fs ${../dotfiles}/.taskrc
      touch .zshrc
      chown danielrf:danielrf .zshrc
    '';
  };
}
