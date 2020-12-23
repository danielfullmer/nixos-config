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
    ./zerotier.nix
  ];

  # Self-signed Certificate Authority I use to sign other certs
  security.pki.certificateFiles = [ ../certs/ca.crt ];

  services.openssh.enable = true;
  #services.fail2ban.enable = true; # Currently causes problems restarting, See fail2ban PR 1618. nixpkgs out of date

  networking.domain = "daniel.fullmer.me";
  services.ssmtp = {
    enable = true;
    hostName = "bellman";
    root = "cgibreak@gmail.com";
  };

  security.acme = {
    acceptTerms = true;
    email = "danielrf12@gmail.com";
  };

  networking.nameservers = [ "127.0.0.1" ];
  systemd.services.unbound = {
    wantedBy = [ "network.target" ];
    before = [ "network.target" ];
  };
  services.unbound = {
    enable = true;

    # services.unbound.forwardAddresses doesn't let us set forward-tls-upstream
    extraConfig = ''
      forward-zone:
        name: "."
        forward-tls-upstream: yes
        # Cloudflare DNS
        forward-addr: 2606:4700:4700::1111@853#cloudflare-dns.com
        forward-addr: 1.1.1.1@853#cloudflare-dns.com
        forward-addr: 2606:4700:4700::1001@853#cloudflare-dns.com
        forward-addr: 1.0.0.1@853#cloudflare-dns.com
        # Quad9
        forward-addr: 2620:fe::fe@853#dns.quad9.net
        forward-addr: 9.9.9.9@853#dns.quad9.net
        forward-addr: 2620:fe::9@853#dns.quad9.net
        forward-addr: 149.112.112.112@853#dns.quad9.net
        # TOR
        #forward-addr: 127.0.0.1@853#cloudflare-dns.com

      server:
        tls-cert-bundle: /etc/pki/tls/certs/ca-bundle.crt
        do-not-query-localhost: no
        edns-tcp-keepalive: yes
    '';
  };

  # Hook up dnsmasq (if used) to unbound
  services.dnsmasq = {
    servers = [ "127.0.0.1" ];
    resolveLocalQueries = false;
    extraConfig = ''
      except-interface=lo
      bind-interfaces
      no-hosts
    '';
  };

  # Provides cloudflare DNS over TOR
  systemd.services.tor-dns = {
    script = ''
      ${pkgs.socat}/bin/socat TCP4-LISTEN:853,bind=127.0.0.1,reuseaddr,fork SOCKS4A:127.0.0.1:dns4torpnlfs2ifuz2s2yf3fc7rdmsbhm6rw75euj35pac6ap25zgqad.onion:853,socksport=9063
    '';
    wantedBy = [ "unbound.service" ];
  };

  environment.etc."wpa_supplicant.conf" = lib.mkIf (config.networking.wireless.enable || config.networking.networkmanager.enable) { source = "/var/secrets/wpa_supplicant.conf"; };
  secrets."wpa_supplicant.conf" = lib.mkIf (config.networking.wireless.enable || config.networking.networkmanager.enable) {};

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
    nixPath = [
      "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos" # Removed trailing /nixpkgs, which was just a symlink to .
      "nixos-config=/nix/var/nix/profiles/per-user/root/channels/config-tested/machines/${config.networking.hostName}"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];

    autoOptimiseStore = true;
    useSandbox = true;
    trustedUsers = [ "root" "danielrf" ];

    binaryCaches = [ "https://cache.nixos.org/" "https://daniel.cachix.org/" ];

    trustedBinaryCaches = lib.optional (config.networking.hostName != "bellman") "https://hydra.daniel.fullmer.me";

    binaryCachePublicKeys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "bellman-1:zgaxZSNzvCMGY5sjjgsxEC2uKn3OTW9LWEN0uhjJoO4="
      "daniel.cachix.org-1:0DFbZ4j3tqoJyqlV8TTd2Vz+CdqKwyuYPTaDPioz4vw="
    ];

    daemonIONiceLevel = 5; # Range: 0-7
  };
  systemd.services.nix-daemon.serviceConfig = {
    CPUSchedulingPolicy = "batch";
  };

  users = {
    groups = {
      danielrf = {};
      vboxsf = {};
    };
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

  time.timeZone = "America/Los_Angeles";
  time.hardwareClockInLocalTime = true;

  nixpkgs.config = import ../pkgs/config.nix;
  nixpkgs.overlays =  [ (import ../pkgs/default.nix { _config=config; }) ];
}
