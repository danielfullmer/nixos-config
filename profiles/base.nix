{ config, pkgs, lib, ... }:
let
  ssh-yubikey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDMTGWu4gkXsWewBZg5if04qt5lyEAKwhi12wmn5e2hKvVLlTlIq8gGBF7d/Xv8G2NlHRsNkugeYyBtB2qfkPWtcDnd1+ws78UTUbYDPpZJzRnIjUEzAg8Q5DzgD9feGHmpONmsr6K71ZGJFwQH2Vf8RHzYIzAYPY85raQiV2Akpw9QtWjp48sNUKoJ75ZWZWzQdJtouJYZRnrK+gweKVWFB0cv7qrIgSOFHAjGJLON+cMXN+T/VIDSZITCRcVLBMlYYGv5NZecspRPO1UV0bgWNHZ3dZwJOEk6cPYUdyA/761zhCWCUc7MJH5xEz3sxcqBSmxtwFYvDFDWkWYcD1gh yubikey";
in
{
  imports = [
    ../modules/theme
    ../modules/desktop.nix
  ];

  services.openssh.enable = true;
  services.fail2ban.enable = true;

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

  # X11 and GPG forwarding for SSH
  # See https://wiki.gnupg.org/AgentForwarding
  # TODO: /run/user/ path is not correct if UID is different across hosts
  programs.ssh.extraConfig = ''
    Host bellman nyquist euler
    ForwardAgent yes
    ForwardX11 yes
    RemoteForward /run/user/1000/gnupg/S.gpg-agent /run/user/1000/gnupg/S.gpg-agent.extra
  '';
  services.openssh.forwardX11 = true;
  services.openssh.extraConfig = ''
    StreamLocalBindUnlink yes
  '';

  nix = {
    autoOptimiseStore = true;
    useSandbox = true;
    trustedUsers = [ "root" "danielrf" "nixBuild" ];

    binaryCaches = [
      "https://cache.nixos.org/"
    ] ++ lib.optional (config.networking.hostName != "bellman") "http://bellman:5000";

    binaryCachePublicKeys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "bellman-1:zgaxZSNzvCMGY5sjjgsxEC2uKn3OTW9LWEN0uhjJoO4="
    ];

    daemonNiceLevel = 10; # Range: 0-19
    daemonIONiceLevel = 5; # Range: 0-7
  };

  users = {
    groups = [ { name = "danielrf"; } { name = "vboxsf"; } ];
    users = {
      danielrf = {
        description     = "Daniel Fullmer";
        group           = "danielrf";
        extraGroups     = [ "users" "wheel" "video" "audio" "networkmanager"
                            "vboxsf" "docker" "libvirtd" "systemd-journal"
                          ];
        home            = "/home/danielrf";
        createHome      = true;
        password        = "changeme";
        shell           = "/run/current-system/sw/bin/zsh";
        openssh.authorizedKeys.keys = [ ssh-yubikey ];
      };
      root.openssh.authorizedKeys.keys = [ ssh-yubikey ];
    };
  };

  services.cron.mailto = "cgibreak@gmail.com";

  time.timeZone = "America/New_York";
  time.hardwareClockInLocalTime = true;

  security.sudo.wheelNeedsPassword = false;

  nixpkgs.config = import ../pkgs/config.nix { pkgs=pkgs; theme=config.theme; };

  environment.systemPackages = (with pkgs; [
    binutils
    pciutils
    usbutils
    psmisc
    htop
    ncdu
    bmon

    tmux

    silver-searcher
    git

    neovim
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

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting = {
      enable = true;
      highlighters = [ "main" "brackets" ];
    };
    enableAutosuggestions = true;
    promptInit = "source ${../pkgs/zsh/zshrc.prompt}";
    interactiveShellInit = import (../modules/theme/templates + "/shell.${config.theme.brightness}.nix") { colors=config.theme.colors; };
  };

  programs.fish = {
    enable = true;
    interactiveShellInit =
      let shellThemeScript = pkgs.writeScript "shellTheme"
        (import (../modules/theme/templates + "/shell.${config.theme.brightness}.nix") { colors=config.theme.colors; });
      in
      ''
        eval sh ${shellThemeScript}
      '';
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
  };
}
