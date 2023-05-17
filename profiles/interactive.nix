# interactive.nix: Intended for hosts that I would at least SSH into.

{ config, pkgs, lib, ... }:
let
  userBin = pkgs.runCommand "user-bin" {} "mkdir -p $out/bin; cp ${./bin}/* $out/bin/";
in
{
  imports =  [
    ./keyboard.nix
  ];

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

    libarchive # Provides bsdtar, for unzipping stuff

    tmux
    silver-searcher
    ripgrep
    fzf
    gh

    # Stuff for nvim
    neovim
    #nodePackages.typescript-language-server
    nil nixpkgs-fmt
    #(python38.withPackages (p: with p; [
    #  python-language-server pyls-mypy pyls-isort pyls-flake8
    #]))
    # haskell-language-server # Too Heavy

    taskwarrior
    taskwarrior-tui
    timewarrior
    vit

    sops
    direnv

    gnupg
    pass
    #(pass.withExtensions (p: with p; [ pass-audit])) # 2020-06-18: broken in nixpkgs

    userBin
  ]);

  environment.variables = {
    EDITOR = "${pkgs.neovim}/bin/vim";

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
  users.defaultUserShell = "/run/current-system/sw/bin/zsh";

  programs.command-not-found.enable = true;

  environment.etc."tmux.conf".text = config.programs.tmux.config;

  environment.interactiveShellInit = ''
    eval $(${pkgs.coreutils}/bin/dircolors "${./dircolors}")
  '';

  programs.bash.interactiveShellInit = ''
    eval "$(direnv hook bash)"
  '';

  programs.zsh.interactiveShellInit = ''
    eval "$(direnv hook zsh)"
  '';

  environment.extraInit = ''
    export PATH="$HOME/.local/bin:$PATH"
  '';

  environment.shellAliases = {
    ls = "ls --color";
    vi = "vim";
    nfo="iconv -f IBM775";
    t = "task rc.context=$(cat $HOME/.task-context)";
    tw = "timew";
  };

#  # This is a hack
#  system.activationScripts = {
#    dotfiles = lib.stringAfter [ "users" ]
#    ''
#      cd /home/danielrf
#      mkdir -p .gnupg
#      chown danielrf:danielrf .gnupg
#      chmod 700 .gnupg
#      ln -fs ${../dotfiles}/.latexmkrc
#      ln -fs ${../dotfiles}/.taskrc
#      touch .zshrc
#      chown danielrf:danielrf .zshrc
#    '';
#  };

  # Use gpg-agent instead of system-wide ssh-agent
  programs.ssh.startAgent = false;
  programs.ssh.askPassword = "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";
  programs.gnupg = {
    agent.enable = true;
    agent.enableSSHSupport = true;
    agent.enableExtraSocket = true;
    agent.enableBrowserSocket = true;
    dirmngr.enable = true;
  };

  systemd.services.gpg-key-import = {
    description = "Import gpg keys";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "danielrf";
      Group = "danielrf";
    };
    script = ''
      ${lib.getBin pkgs.gnupg}/bin/gpg --import ${../keys/users/danielfullmer-yubikey.asc} ${../keys/users/danielfullmer-offlinekey.asc}
      ${lib.getBin pkgs.gnupg}/bin/gpg --import-ownertrust << EOF
      FA0ED54AE0DBF4CDC4B4FEADD1481BC2EF6B0CB0:6:
      7242A6FEF237A429E981576F6EDF0AEEA2D9FA5D:6:
      EOF
    '';
    # TODO: Maybe create a udev rule to run "gpg --card-status" when yubikey plugged in first time
  };
}
