{ config, pkgs, lib, ... }:
with lib;
let
  ssh-yubikey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDMTGWu4gkXsWewBZg5if04qt5lyEAKwhi12wmn5e2hKvVLlTlIq8gGBF7d/Xv8G2NlHRsNkugeYyBtB2qfkPWtcDnd1+ws78UTUbYDPpZJzRnIjUEzAg8Q5DzgD9feGHmpONmsr6K71ZGJFwQH2Vf8RHzYIzAYPY85raQiV2Akpw9QtWjp48sNUKoJ75ZWZWzQdJtouJYZRnrK+gweKVWFB0cv7qrIgSOFHAjGJLON+cMXN+T/VIDSZITCRcVLBMlYYGv5NZecspRPO1UV0bgWNHZ3dZwJOEk6cPYUdyA/761zhCWCUc7MJH5xEz3sxcqBSmxtwFYvDFDWkWYcD1gh yubikey";
in
{
  imports = [
    ../machines
    ../modules
    ../pkgs/custom-config.nix
  ];

  sops.defaultSopsFile = ../machines + "/${config.networking.hostName}/secrets/secrets.yaml";

  # Save some space by only supporting a few locales
  i18n.supportedLocales = ["en_US.UTF-8/UTF-8" "en_US/ISO-8859-1"];

  # Self-signed Certificate Authority I use to sign other certs
  security.pki.certificateFiles = [ ../certs/ca.crt ];

  services.openssh.enable = true;
  #services.fail2ban.enable = true; # Currently causes problems restarting, See fail2ban PR 1618. nixpkgs out of date

  services.ssmtp = {
    enable = true;
    hostName = "bellman";
    root = "cgibreak@gmail.com";
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "danielrf12@gmail.com";
  };

  environment.etc."wpa_supplicant.conf" = lib.mkIf (config.networking.wireless.enable || config.networking.networkmanager.enable) {
    source = config.sops.secrets."wpa_supplicant.conf".path;
  };
  sops.secrets."wpa_supplicant.conf" = lib.mkIf (config.networking.wireless.enable || config.networking.networkmanager.enable) {
    format = "binary";
    sopsFile = ../secrets/wpa_supplicant.conf;
  };

  boot.cleanTmpDir = true;

  programs.ssh.knownHosts."github.com".publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==";
  # X11 and GPG forwarding for SSH
  # See https://wiki.gnupg.org/AgentForwarding
  # TODO: /run/user/ path is not correct if UID is different across hosts
  programs.ssh.extraConfig = ''
    Host ${concatStringsSep " " (attrNames config.machines.sshPublicKey)}
    #ForwardAgent yes
    ForwardX11 yes
    #RemoteForward /run/user/1000/gnupg/S.gpg-agent /run/user/1000/gnupg/S.gpg-agent.extra
  '';
  services.openssh.forwardX11 = !config.environment.noXlibs;
  services.openssh.extraConfig = ''
    StreamLocalBindUnlink yes
  '';

  nix = {
    autoOptimiseStore = true;
    useSandbox = true;
    trustedUsers = [ "root" "danielrf" ];

    # binaryCaches = [ "https://daniel.cachix.org/" ];

    # trustedBinaryCaches = lib.optional (config.networking.hostName != "bellman") "https://hydra.daniel.fullmer.me";

    binaryCachePublicKeys = [
      "bellman-1:zgaxZSNzvCMGY5sjjgsxEC2uKn3OTW9LWEN0uhjJoO4="
      #"daniel.cachix.org-1:0DFbZ4j3tqoJyqlV8TTd2Vz+CdqKwyuYPTaDPioz4vw="
    ];

    daemonIOSchedPriority = 5; # Range: 0-7
    daemonCPUSchedPolicy = "batch";
  };

  users = {
    groups = {
      danielrf = {};
      vboxsf = {};
    };
    users = {
      danielrf = {
        isNormalUser = true;
        description = "Daniel Fullmer";
        group = "danielrf";
        extraGroups = [
          "users" "wheel" "video" "audio" "networkmanager" "vboxsf" "docker"
          "libvirtd" "systemd-journal"
        ];
        initialPassword = "changeme";
        openssh.authorizedKeys.keys = [ ssh-yubikey ];
      };
      root.openssh.authorizedKeys.keys = [ ssh-yubikey ];
    };
  };

  services.cron.mailto = "cgibreak@gmail.com";

  time.timeZone = "America/Los_Angeles";
  time.hardwareClockInLocalTime = true;

  nixpkgs.config = import ../pkgs/config.nix;
  nixpkgs.overlays =  [ (import ../pkgs/overlay.nix { _config=config; }) ];
}
