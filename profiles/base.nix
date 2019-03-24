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

  services.zerotierone.enable = true;
  services.zerotierone.joinNetworks = [ "8056c2e21c36f91e" ];
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
    "30.0.0.248" = [ "pixel" ];
  };

  programs.ssh.knownHosts = {
    bellman.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII3vpFuoazTclho9ew0EFP+QhanahZtASGBCUk5oxBGW";
    nyquist.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBEOwL+5XKdvVBNGIT4pUfzNtMyvuvERwWAcE9q8HFVj";
    wrench.publicKey = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBM6M2q7YcOoHWQRpok1euwQ8FChG34GxxlijFtLHL6uO2myUpstpfvaF4K0Rm5rkiaXGmFZAjgj132JO98JbL1k=";
    banach.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKGfJCTIzSct/m/Zm/yUb224JhKmr35ISH2CEcxSbkCc";
    "github.com".publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==";
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
  services.openssh.forwardX11 = !config.environment.noXlibs;
  services.openssh.extraConfig = ''
    StreamLocalBindUnlink yes
  '';

  nix = {
    nixPath = [ # From nixos/modules/services/misc/nix-daemon.nix
      "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos" # Removed trailing /nixpkgs, which was just a symlink to .
      "nixos-config=/etc/nixos/configuration.nix"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];

    autoOptimiseStore = true;
    useSandbox = true;
    trustedUsers = [ "root" "danielrf" "nixBuild" ];

    binaryCaches = [ "https://cache.nixos.org/" "https://daniel.cachix.org/" ];

    trustedBinaryCaches = lib.optional (config.networking.hostName != "bellman") "http://bellman:5000";

    binaryCachePublicKeys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "bellman-1:zgaxZSNzvCMGY5sjjgsxEC2uKn3OTW9LWEN0uhjJoO4="
      "daniel.cachix.org-1:0DFbZ4j3tqoJyqlV8TTd2Vz+CdqKwyuYPTaDPioz4vw="
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
}
