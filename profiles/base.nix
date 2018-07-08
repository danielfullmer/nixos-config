{ config, pkgs, lib, ... }:
let
  ssh-yubikey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDMTGWu4gkXsWewBZg5if04qt5lyEAKwhi12wmn5e2hKvVLlTlIq8gGBF7d/Xv8G2NlHRsNkugeYyBtB2qfkPWtcDnd1+ws78UTUbYDPpZJzRnIjUEzAg8Q5DzgD9feGHmpONmsr6K71ZGJFwQH2Vf8RHzYIzAYPY85raQiV2Akpw9QtWjp48sNUKoJ75ZWZWzQdJtouJYZRnrK+gweKVWFB0cv7qrIgSOFHAjGJLON+cMXN+T/VIDSZITCRcVLBMlYYGv5NZecspRPO1UV0bgWNHZ3dZwJOEk6cPYUdyA/761zhCWCUc7MJH5xEz3sxcqBSmxtwFYvDFDWkWYcD1gh yubikey";
in
{
  imports = [
    ../modules
  ];

  services.openssh.enable = true;
  #services.fail2ban.enable = true; # Currently causes problems restarting, See fail2ban PR 1618. nixpkgs out of date

  networking.domain = "controlnet";
  networking.defaultMailServer = {
    directDelivery = true;
    hostName = "bellman";
    root = "cgibreak@gmail.com";
  };

  boot.cleanTmpDir = true;
  #boot.tmpOnTmpfs = true; # XXX: Too much memory usage

  services.zerotierone.enable = true;
  services.zerotierone.joinNetworks = [ "8056c2e21c36f91e" ];
  systemd.services.zerotierone.wants = [ "network-online.target" ]; # Workaround for https://github.com/zerotier/ZeroTierOne/issues/738
  networking.dhcpcd.denyInterfaces = [ "ztmjfpigyc" ]; # Network name generated from network ID in zerotier osdep/LinuxEthernetTap.cpp
  networking.firewall.trustedInterfaces = [ "ztmjfpigyc" ];
  networking.firewall.allowedUDPPorts = [ 9993 ]; # Inbound UDP 9993 for zerotierone
  networking.hosts = { # TODO: Parameterize
    "30.0.0.48" = [ "devnull" ];
    "30.0.0.154" = [ "sysc-2" ];
    "30.0.0.127" = [ "nyquist" ];
    "30.0.0.222" = [ "bellman" ];
    "30.0.0.34" = [ "wrench" ];
    "30.0.0.86" = [ "euler" ];
    "30.0.0.84" = [ "gauss" ];
    "30.0.0.156" = [ "banach" ];
    "30.0.0.40" = [ "spaceheater" ];
  };

  programs.ssh.knownHosts = {
    bellman.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILUIB2rle04uPIk5TFnGeomYPqfRCbRfjOQw11gsJOye";
    nyquist.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBEOwL+5XKdvVBNGIT4pUfzNtMyvuvERwWAcE9q8HFVj";
    wrench.publicKey = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBM6M2q7YcOoHWQRpok1euwQ8FChG34GxxlijFtLHL6uO2myUpstpfvaF4K0Rm5rkiaXGmFZAjgj132JO98JbL1k=";
    banach.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKGfJCTIzSct/m/Zm/yUb224JhKmr35ISH2CEcxSbkCc";
  };

  # X11 and GPG forwarding for SSH
  # See https://wiki.gnupg.org/AgentForwarding
  # TODO: /run/user/ path is not correct if UID is different across hosts
  # TODO: Parameterize the list of machines
  programs.ssh.extraConfig = ''
    Host bellman nyquist euler banach spaceheater
    ForwardAgent yes
    ForwardX11 yes
    RemoteForward /run/user/1000/gnupg/S.gpg-agent /run/user/1000/gnupg/S.gpg-agent.extra
  '';
  services.openssh.forwardX11 = true;
  services.openssh.extraConfig = ''
    StreamLocalBindUnlink yes
  '';

  # Use DNS-over-TLS
  # TODO: Figure out google's DNS
  services.kresd = {
    enable = true;
    extraConfig = ''
      policy.add(policy.all(policy.TLS_FORWARD({
        { '1.1.1.1', hostname = 'cloudflare-dns.com', ca_file = '/etc/ssl/certs/ca-bundle.crt' },
      })))
      policy.add(policy.all(policy.TLS_FORWARD({
        { '2606:4700:4700::1111', hostname = 'cloudflare-dns.com', ca_file = '/etc/ssl/certs/ca-bundle.crt' },
      })))
      policy.add(policy.all(policy.TLS_FORWARD({
        { '9.9.9.9', hostname = 'dns.quad9.net', ca_file = '/etc/ssl/certs/ca-bundle.crt' },
      })))
      policy.add(policy.all(policy.TLS_FORWARD({
        { '2620:fe::fe', hostname = 'dns.quad9.net', ca_file = '/etc/ssl/certs/ca-bundle.crt' },
      })))
    '';
  };
  networking.nameservers = [ "127.0.0.1" "::1" "8.8.8.8" ];

  nix = {
    nixPath = [ # From nixos/modules/services/misc/nix-daemon.nix
      "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos" # Removed trailing /nixpkgs, which was just a symlink to .
      "nixos-config=/etc/nixos/configuration.nix"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];

    autoOptimiseStore = true;
    useSandbox = true;
    trustedUsers = [ "root" "danielrf" "nixBuild" ];

    binaryCaches = [ "https://cache.nixos.org/" ];

    trustedBinaryCaches = lib.optional (config.networking.hostName != "bellman") "http://bellman:5000";

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

  nixpkgs.config = import ../pkgs/config.nix;
  nixpkgs.overlays = (import ../pkgs/overlays.nix) ++ [
    (self: super: {theme=config.theme;})
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
    FZF_TMUX = "1"; # For fzf zsh scripts
  };

  programs.bash = {
    enableCompletion = true;
    interactiveShellInit = ''
      source ${pkgs.fzf}/share/fzf/completion.bash # Activated with **<TAB>
      source ${pkgs.fzf}/share/fzf/key-bindings.bash # CTRL-R and CTRL-T
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
      source ${pkgs.fzf}/share/fzf/key-bindings.zsh # CTRL-R and CTRL-T
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
