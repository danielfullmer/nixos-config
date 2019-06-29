{ config, lib, pkgs, ... }:

{
  imports = [
    ../profiles/base.nix
    ../profiles/interactive.nix
    ../profiles/extended.nix
    ../profiles/yubikey.nix
    ../profiles/syncthing.nix
    ../profiles/desktop/default.nix
    ../profiles/monitors-calibrate.nix
    ../profiles/gaming.nix
    ../profiles/academic.nix
    ../profiles/postfix.nix
    ../profiles/gdrive.nix
    #../profiles/backup.nix
  ];

  theme.base16Name = "chalk";

  system.stateVersion = "18.03";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.rtl8812au ];
  hardware.firmware = [ pkgs.firmwareLinuxNonfree ];  # For any other wifi firmware


  boot.initrd.availableKernelModules = [
    "xhci_pci" "ehci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"
  ];

  # Current partition status:
  # One zfs with mirrored 2x 2Tb HDDs, backed with 1x 500GB SSD
  # Seagate 2TB ST2000DM006 has 4096 size blocks: ashift=12
  # Samsung SSD 850/860 EVO 500G have 8192 size blocks: ashift=13
  boot.supportedFilesystems = [ "zfs" ];
  boot.initrd.supportedFilesystems = [ "zfs" ];
  boot.zfs.enableUnstable = true;
  services.zfs.autoScrub.enable = true;

  fileSystems = {
    "/" = { device = "pool/root"; fsType = "zfs"; };
    "/home" = { device = "pool/home"; fsType = "zfs"; };
    "/nix" = { device = "pool/nix"; fsType = "zfs"; };
    "/tmp" = { device = "pool/tmp"; fsType = "zfs"; };

    "/boot" = {
      device = "/dev/disk/by-uuid/3AF1-2802";
      fsType = "vfat";
    };
  };

  swapDevices = [ ];

  nix.maxJobs = 2;
  nix.buildCores = 4;

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

  services.xserver.xrandrHeads = [
    { output = "DP-0"; primary = true; }
    { output = "DP-4"; }
    { output = "DP-5"; }
    { output = "DVI-D-0";
      monitorConfig = ''
        Option "Rotate" "Left"
      '';
    }
  ];

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
    package = pkgs.hydra.overrideAttrs (attrs: { patches = attrs.patches ++ [ ../pkgs/hydra/no-restrict-eval.patch ]; });
  };
  secrets."hydra-nix-key.sec" = { user = "hydra"; group = "hydra"; };
  services.nginx.virtualHosts."hydra.daniel.fullmer.me" = {
    locations."/".proxyPass = "http://127.0.0.1:5001/";
    forceSSL = true;
    enableACME = true;
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
#
#  services.tor = {
#    enable = true;
#    hiddenServices."bellman".map = [
#      { port = 22; } # SSH
#      { port = 8123; } # Home-assistant
#    ];
#  };

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

  networking.hosts = {
    "127.0.0.1" = [ "nextcloud.fullmer.me" "hydra.daniel.fullmer.me" "playmaker.daniel.fullmer.me" ];
  };

  services.nginx.virtualHosts."nextcloud.fullmer.me" = {
    locations."/".proxyPass = "http://10.100.0.2/";
    forceSSL = true;
    enableACME = true;
  };

  networking.nat.enable = true;
  networking.nat.internalIPs = [ "10.100.0.2" ];
  containers.nextcloud = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "10.100.0.1";
    localAddress = "10.100.0.2";
    config = { config, pkgs, ... }:
    {
      networking.useHostResolvConf = true;

      services.nextcloud = {
        enable = true;
        hostName = "nextcloud.fullmer.me";
        nginx.enable = true;
        config = {
          dbtype = "pgsql";
          dbuser = "nextcloud";
          dbhost = "/tmp"; # nextcloud will add /.s.PGSQL.5432 by itself
          dbname = "nextcloud";
          adminpass = "insecure"; # TODO: Fix this
          #adminpassFile = "/path/to/admin-pass-file";
          adminuser = "root";
          extraTrustedDomains = [ "10.100.0.2" ]; # Ensure the "proxyPass" location is a valid domain
          overwriteProtocol = "https"; # Since we're behind nginx reverse proxy, we need to know that we should always use https
        };
      };

      services.postgresql = {
        enable = true;
        initialScript = pkgs.writeText "psql-init" ''
          CREATE ROLE nextcloud WITH LOGIN;
          CREATE DATABASE nextcloud WITH OWNER nextcloud;
        '';
      };

      # ensure that postgres is running *before* running the setup
      systemd.services."nextcloud-setup" = {
        requires = ["postgresql.service"];
        after = ["postgresql.service"];
      };

      networking.firewall.allowedTCPPorts = [ 80 443 ];

      environment.systemPackages = with pkgs; [ ffmpeg imagemagick ghostscript ];
    };
  };

  services.playmaker.enable = true; # Port 5000 (customize in future)
  services.playmaker.device = "walleye"; # This is currently the only device in playmaker/googleplay-api device.properties file that is actually android 9 / API 28
  # Port 5000 has no access control--anyone who can connect can add/remove packages.
  # We'll rely on firewall to ensure only zerotier network can access port 5000,
  # and additionally pass through the fdroid repo it generates via nginx.
  services.nginx.virtualHosts."playmaker.daniel.fullmer.me" = {
    locations."/".proxyPass = "http://127.0.0.1:5000/";
    basicAuthFile = "/var/secrets/htpasswd";
    forceSSL = true;
    enableACME = true;
  };
  secrets."htpasswd" = { user = "nginx"; group = "nginx"; };
  services.nginx.virtualHosts."fdroid.daniel.fullmer.me" = {
    locations."/".proxyPass = "http://127.0.0.1:5000/fdroid/"; # Fdroid client isn't working over SSL for some reason
    forceSSL = true;
    enableACME = true;
  };
}
