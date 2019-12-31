{ config, lib, pkgs, ... }:

let
  # Allow localhost, zerotier, and wireguard hosts
  denyInternet = ''
    allow 127.0.0.1;
    allow ::1;
    allow 30.0.0.0/24;
    allow 10.200.0.0/24;
    deny all;
  '';
in
{
  imports = [
    ../../profiles/base.nix
    ../../profiles/interactive.nix
    ../../profiles/extended.nix
    ../../profiles/yubikey.nix
    ../../profiles/syncthing.nix
    ../../profiles/desktop/default.nix
    ../../profiles/monitors-calibrate.nix
    ../../profiles/gaming.nix
    ../../profiles/academic.nix
    ../../profiles/postfix.nix
    ../../profiles/gdrive.nix
    ../../profiles/wireguard.nix
    ../../profiles/tor.nix
    ../../profiles/nextcloud.nix
    #../../profiles/backup.nix
    ../../xrdesktop-overlay
  ];

  networking.hostName = "bellman"; # Define your hostname.
  networking.hostId = "f6bb12be";
  #networking.wireless.enable = true;
  networking.networkmanager.enable = true;

  services.acpid.enable = true;

  services.xserver.videoDrivers = [ "nvidia" "intel" ];

  services.redshift.enable = true;

  # For Seiki 4K monitor
  fonts.fontconfig.dpi = 115;
  fonts.fontconfig.subpixel.rgba = "bgr";
  theme.fontSize = 12;
#  services.xserver.monitorSection = ''
#    DisplaySize 698 393
#  '';

#  services.xserver.xrandrHeads = [
#    { output = "DP-0"; primary = true; }
#    { output = "DP-4"; }
#    { output = "DP-5"; }
#    { output = "DVI-D-0";
#      monitorConfig = ''
#        Option "Rotate" "Left"
#      '';
#    }
#  ];
  services.xserver.screenSection = ''
    Option         "Stereo" "0"
    Option         "metamodes" "DVI-D-0: nvidia-auto-select +3840+0 {rotation=left}, DP-2: 3840x2160 +0+200, DP-4: NULL"
    Option         "SLI" "Off"
    Option         "MultiGPU" "Off"
    Option         "BaseMosaic" "off"
  '';

  # For serial interface to reflash x39 monitor firmware
  services.udev.packages = lib.singleton (pkgs.writeTextFile {
    name = "uart-udev-rules";
    destination = "/etc/udev/rules.d/51-uart-custom.rules";
    text = ''
      SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", ATTRS{product}=="FT232R USB UART", TAG+="uaccess", SYMLINK+="arduino"
    '';
  });

  # For flashing android stuff
  programs.adb.enable = true;
  users.users.danielrf.extraGroups = [ "adbusers" ];

  services.xserver.desktopManager.extraSessionCommands =
    let synergyConfigFile = pkgs.writeText "synergy.conf" ''
      section: screens
          bellman:
          devnull-PC:
          euler-win:
      end
      section: aliases
      end
      section: links
      bellman:
          right = devnull-PC
          down = euler-win
      devnull-PC:
          left = bellman
      euler-win:
          up = bellman
      end
    '';
    in ''
      (${pkgs.synergy}/bin/synergys -c ${synergyConfigFile} -a 30.0.0.222:24800) &
      (yubioath-gui -t) &
      (keybase-gui) &
      (signal-desktop --start-in-tray) &
    '';

  services.nginx.enable = true;
  services.nginx.recommendedProxySettings = true;
  services.nginx.virtualHosts."daniel.fullmer.me" = {
    default = true;
    forceSSL = true;
    enableACME = true;
    root = "/data/webroot";
  };
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.hydra = {
    enable = true;
    listenHost = "localhost";
    port = 5001;
    hydraURL = "https://hydra.daniel.fullmer.me/";
    notificationSender = "cgibreak@gmail.com";
    smtpHost = "${config.networking.hostName}";
    useSubstitutes = true;
    #buildMachinesFiles = [ ../profiles/hydra-remote-machines ];
    # This is a deprecated option, but it's still used by NARInfo.pm
    extraConfig = "binary_cache_secret_key_file = /var/secrets/bellman-nix-key.sec";

    # Patch to allow builtins.fetchTarball
    package = pkgs.hydra.overrideAttrs (attrs: { patches = (if attrs ? patches then attrs.patches else []) ++ [ ../../pkgs/hydra/no-restrict-eval.patch ]; });
  };
  secrets."hydra-nix-key.sec" = { user = "hydra"; group = "hydra"; };
  services.nginx.virtualHosts."hydra.daniel.fullmer.me" = {
    locations."/".proxyPass = "http://127.0.0.1:5001/";
    forceSSL = true;
    enableACME = true;
    extraConfig = denyInternet;
  };

  boot.binfmt.emulatedSystems = [ "armv6l-linux" "armv7l-linux" "aarch64-linux" ];

    # TOOD: Parameterize
    # Used by hydra even if nix.distributedBuilds is false
  nix.buildMachines = [
    { hostName = "localhost";
      #sshUser = "nix";
      #sshKey = "/none";
      system = "x86_64-linux,i686-linux,aarch64-linux";
      maxJobs = 4;
      supportedFeatures = [ "kvm" "nixos-test" "big-parallel" "benchmark" ];
    }
#    { hostName = "nyquist";
#      #sshUser = "nix";
#      #sshKey = "/none";
#      system = "x86_64-linux,i686-linux";
#      maxJobs = 4;
#      supportedFeatures = [ ];
#    }
#    { hostName = "banach";
#      #sshUser = "nix";
#      #sshKey = "/none";
#      system = "aarch64-linux";
#      maxJobs = 2;
#      supportedFeatures = [ ];
#    }
  ];
  #nix.distributedBuilds = true;

  # Remote hosts often have better connection to cache than direct to this host
  nix.extraOptions = ''
    builders-use-substitutes = true
    secret-key-files = /var/secrets/bellman-nix-key.sec
  '';
  secrets."bellman-nix-key.sec" = {};

#  services.home-assistant.enable = true;

  systemd.user.services.gmailieer = {
    serviceConfig = {
      ExecStart = "${pkgs.gmailieer}/bin/gmi sync";
      Type = "oneshot";
      WorkingDirectory = "/home/danielrf/mail/cgibreak.gmail";
    };
  };

  systemd.user.timers.gmailieer = {
    requires = [ "network-online.target" ];
    wantedBy = [ "timers.target" ];
    timerConfig = {
      Unit = "gmailieer.service";
      OnCalendar = "*:0/3"; # Every 3 minutes
    };
  };

  environment.systemPackages = with pkgs; [
    bcachefs-tools keyboard-firmware
    signal-desktop
  ];

  system.autoUpgrade.enable = true;

  # Router ipv6 isn't working. Lets tunnel through tunnelbroker.net. Notably helps zerotier connections as well
  # TODO: Nixify this. Add a periodic client IP udpate
  networking.localCommands = ''
    ip tunnel add he-ipv6 mode sit remote 209.51.161.14 ttl 255
    ip link set he-ipv6 up
    ip addr add 2001:470:1f06:bae::2/64 dev he-ipv6
    ip route add ::/0 dev he-ipv6 pref high
  '';
#  networking.sits."he-ipv6" = {
#    dev = "he-dummy"; # TODO: See below
#    remote = "209.51.161.14";
#    ttl = 255;
#  };
#  systemd.services."he-ipv6-netdev".bindsTo = lib.mkForce []; # Otherwise networking.sits.he-ipv6.dev must be set and it forces a hard dependency
#  systemd.services."he-ipv6-netdev".after = lib.mkForce [ "network-pre.target" ];
#  networking.interfaces."he-ipv6" = {
#    ipv6.addresses = [ { address = "2001:470:1f06:bae::2"; prefixLength = 64; } ];
#    ipv6.routes = [ { address = "::"; prefixLength = 0; } ];
#  };


  services.playmaker.enable = true; # Port 5000 (customize in future)
  services.playmaker.device = "walleye"; # This is currently the only device in playmaker/googleplay-api device.properties file that is actually android 9 / API 28
  # Port 5000 has no access control--anyone who can connect can add/remove packages.
  # We'll rely on firewall to ensure only zerotier network can access port 5000,
  # and additionally pass through the fdroid repo it generates via nginx.
  services.nginx.virtualHosts."playmaker.daniel.fullmer.me" = {
    locations."/".proxyPass = "http://127.0.0.1:5000/";
    forceSSL = true;
    enableACME = true;
    extraConfig = denyInternet;
  };
  secrets."htpasswd" = { user = "nginx"; group = "nginx"; };
  services.nginx.virtualHosts."fdroid.daniel.fullmer.me" = {
    locations."/".proxyPass = "http://127.0.0.1:5000/fdroid/"; # Fdroid client isn't working over SSL for some reason
    forceSSL = true;
    enableACME = true;
  };

  services.attestation-server = {
    enable = true;
    domain = "attestation.daniel.fullmer.me";
    listenHost = "127.0.0.1";
    port = 8085;
    # TODO: Extract from NixDroid configuration
    deviceFamily = "crosshatch";
    signatureFingerprint = "30E3A2C19024A208DF0D4FE0633AE3663B22AD4868F446B1AC36D526CA8E95FA";
    avbFingerprint = "F7B29168803BA73C31641D2770C2A84D4FF68C157F0B8BFE0BDC1958D4310491";
  };
  services.nginx.virtualHosts."${config.services.attestation-server.domain}" = {
    locations."/".root = config.services.attestation-server.package.static;
    locations."/api/".proxyPass = "http://${config.services.attestation-server.listenHost}:${toString config.services.attestation-server.port}/api/";
    locations."/challenge".proxyPass = "http://${config.services.attestation-server.listenHost}:${toString config.services.attestation-server.port}/challenge";
    locations."/verify".proxyPass = "http://${config.services.attestation-server.listenHost}:${toString config.services.attestation-server.port}/verify";
    forceSSL = true;
    enableACME = true;
    extraConfig = denyInternet;
  };

  # For testing xrdesktop
  services.xserver.desktopManager.gnome3.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  programs.ccache.enable = true;
}
