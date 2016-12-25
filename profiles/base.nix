{ theme }:

{ config, pkgs, lib, ... }:
{
  services.openssh.enable = true;

  networking.domain = "controlnet";

  boot.cleanTmpDir = true;
  boot.tmpOnTmpfs = true;

  services.zerotierone.enable = true;
  networking.firewall.trustedInterfaces = [ "zt0" ];
  networking.extraHosts = ''
    30.0.0.48 devnull
    30.0.0.154 sysc-2
    30.0.0.127 nyquist
    30.0.0.222 bellman
    30.0.0.34 wrench
    30.0.0.86 euler
    30.0.0.84 gauss
    '';

  nix = {
    extraOptions = ''
      auto-optimize-store = true
    '';
    trustedUsers = [ "root" "danielrf" "nixBuild" ];
  };

  users = {
    groups = [ { name = "danielrf"; } { name = "vboxsf"; } ];
    users  = [
      {
        description     = "Daniel Fullmer";
        name            = "danielrf";
        group           = "danielrf";
        extraGroups     = [ "users" "wheel" "video" "audio" "networkmanager" "vboxsf" "docker" "libvirtd"];
        home            = "/home/danielrf";
        createHome      = true;
        password        = "changeme";
        shell           = "/run/current-system/sw/bin/fish";
        openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDMTGWu4gkXsWewBZg5if04qt5lyEAKwhi12wmn5e2hKvVLlTlIq8gGBF7d/Xv8G2NlHRsNkugeYyBtB2qfkPWtcDnd1+ws78UTUbYDPpZJzRnIjUEzAg8Q5DzgD9feGHmpONmsr6K71ZGJFwQH2Vf8RHzYIzAYPY85raQiV2Akpw9QtWjp48sNUKoJ75ZWZWzQdJtouJYZRnrK+gweKVWFB0cv7qrIgSOFHAjGJLON+cMXN+T/VIDSZITCRcVLBMlYYGv5NZecspRPO1UV0bgWNHZ3dZwJOEk6cPYUdyA/761zhCWCUc7MJH5xEz3sxcqBSmxtwFYvDFDWkWYcD1gh yubikey"
        ];
      }
    ];
  };

  services.cron.mailto = "cgibreak@gmail.com";

  time.timeZone = "America/New_York";
  time.hardwareClockInLocalTime = true;

  security.sudo.wheelNeedsPassword = false;

  nixpkgs.config = import ../pkgs/config.nix { inherit pkgs theme; };

  environment.systemPackages = (with pkgs; [
    binutils
    pciutils
    usbutils
    psmisc
    htop

    tmux

    silver-searcher
    git

    nvim
    emacs

    zerotierone
    pandoc

    bitlbee
    weechat
    mutt
    taskwarrior
  ]);

  environment.variables = {
    EDITOR = "vim";
  };

  programs.zsh.enable = true;
  programs.zsh.interactiveShellInit = import ../pkgs/zsh/zshrc.nix { inherit pkgs theme; };

  programs.fish.enable = true;
  programs.fish.interactiveShellInit = let
    themeScript = pkgs.writeTextFile {
      name = "fishTheme";
      text = import (../pkgs/shell + "/theme.${theme.brightness}.nix") { colors=theme.colors; };
    };
    in
    "eval sh ${themeScript}";

  environment.etc."tmux.conf".text = import ../pkgs/tmux/tmux.conf.nix { inherit pkgs; };

  environment.shellInit = ''
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
  };
}
