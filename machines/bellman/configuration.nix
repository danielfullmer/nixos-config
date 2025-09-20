{ config, lib, pkgs, ... }:

{
  imports = [
    ../../profiles/personal.nix
    ../../profiles/dns.nix
    ../../profiles/interactive.nix
    ../../profiles/extended.nix
    ../../profiles/oled.nix
    ../../profiles/zerotier.nix
    ../../profiles/kdeconnect.nix
    ../../profiles/yubikey.nix
    #../../profiles/syncthing.nix
    ../../profiles/desktop/default.nix
    ../../profiles/monitors-calibrate.nix
    ../../profiles/gaming.nix
    ../../profiles/academic.nix
    ../../profiles/postfix.nix
    ../../profiles/gdrive.nix
    ../../profiles/wireguard.nix
    ../../profiles/tor.nix
    ../../profiles/cuttlefish.nix
    ../../profiles/nextcloud.nix
    #../../xrdesktop-overlay
    ../../profiles/noether-remote-builder.nix

    ../../profiles/rtlsdr.nix

    #../../profiles/robotnix-infra.nix

    #./ap.nix
    #./vfio.nix
    #../../profiles/pxe-server.nix
    #../../profiles/pg-upgrade.nix
  ];

  networking.hostName = "bellman"; # Define your hostname.
  networking.hostId = "f6bb12be";

  system.stateVersion = "18.03";
  services.postgresql.package = pkgs.postgresql_13; # Override outdated one from stateVersion

  #networking.wireless.enable = true;
  #networking.networkmanager.enable = true;
  #networking.interfaces.enp68s0.useDHCP = true;

  # 2.5/5Gbit (red) interface
  networking.interfaces.enp69s0 = {
    #useDHCP = true;
    #macAddress = "b4:2e:99:a7:0b:e8";

    ipv4.addresses = [ { address = "192.168.1.200"; prefixLength = 24; } ];
    ipv4.routes = [ { address = "0.0.0.0"; prefixLength = 0; via = "192.168.1.1"; } ];
  };
  networking.firewall.interfaces.enp69s0.allowedUDPPorts = [ 68 ]; # DHCP Client
  #networking.firewall.interfaces.enp69s0.allowedTCPPorts = [ 32400 ]; # plex
  networking.nat.externalInterface = "enp69s0";

  networking.useDHCP = false;
#  networking.interfaces.enp68s0 = {
#    ipv4.addresses = [ { address = "192.168.1.200"; prefixLength = 24; } ];
#    ipv4.routes = [ { address = "0.0.0.0"; prefixLength = 0; via = "192.168.1.1"; } ];
#  };

#  networking.vlans = {
#    netboot = {
#      id = 3;
#      interface = "enp68s0";
#    };
#  };

  # Firewall
  services.openssh.openFirewall = false;
  # 1935 # RTMP
  # 10000 # SRT
  networking.firewall.interfaces.ztmjfpigyc.allowedTCPPorts = [ 22 80 443 1935 10000 ];
  networking.firewall.interfaces.wlo2.allowedTCPPorts = [ 22 80 443 1935 10000 ];
  networking.firewall.interfaces.wg0.allowedTCPPorts = [ 22 80 443 1935 10000 ];

  services.acpid.enable = true;

  services.redshift.enable = true;

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

  services.nginx.enable = true;
  services.nginx.recommendedProxySettings = true;
  services.nginx.clientMaxBodySize = "1024m";
  services.nginx.virtualHosts."daniel.fullmer.me" = {
    default = true;
    public = true;
    root = "/data/webroot";
  };

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
    extraConfig = "binary_cache_secret_key_file = ${config.sops.secrets.nix-key.path}";

    buildMachinesFiles = [
      "/etc/nix/machines"
      (pkgs.writeText "machines" ''
        localhost x86_64-linux,i686-linux - 8 1 kvm
      '')
    ];
  };
  services.nginx.virtualHosts."hydra.daniel.fullmer.me" = {
    locations."/".proxyPass = "http://127.0.0.1:5001/";
  };

  #boot.binfmt.emulatedSystems = [ "armv6l-linux" "armv7l-linux" "aarch64-linux" ];

  sops.secrets.noether-nixbuilder = {
    owner = config.users.users.hydra-queue-runner.name;
  };
  systemd.services.hydra-queue-runner.serviceConfig.SupplementaryGroups = [ config.users.groups.keys.name ];

  # Remote hosts often have better connection to cache than direct to this host
  nix.extraOptions = ''
    builders-use-substitutes = true
    secret-key-files = ${config.sops.secrets.nix-key.path}
  '';
  sops.secrets.nix-key = {};

  environment.systemPackages = with pkgs; [
    #bcachefs-tools
    #keyboard-firmware
    signal-desktop
  ];

  #system.autoUpgrade.enable = true;

  #virtualisation.anbox.enable = true;

  #services.playmaker.enable = true; # Port 5000 (customize in future)
  services.playmaker.device = "walleye"; # This is currently the only device in playmaker/googleplay-api device.properties file that is actually android 9 / API 28
  # Port 5000 has no access control--anyone who can connect can add/remove packages.
  # We'll rely on firewall to ensure only zerotier network can access port 5000,
  # and additionally pass through the fdroid repo it generates via nginx.
#  services.nginx.virtualHosts."playmaker.daniel.fullmer.me" = {
#    locations."/".proxyPass = "http://127.0.0.1:5000/";
#  };
#  services.nginx.virtualHosts."fdroid.daniel.fullmer.me" = {
#    locations."/".proxyPass = "http://127.0.0.1:5000/fdroid/"; # Fdroid client isn't working over SSL for some reason
#  };

  services.attestation-server = {
    #enable = true;
    domain = "attestation.daniel.fullmer.me";

    # TODO: Extract from robotnix configuration
    device = "crosshatch";
    signatureFingerprint = "30E3A2C19024A208DF0D4FE0633AE3663B22AD4868F446B1AC36D526CA8E95FA";
    avbFingerprint = "F7B29168803BA73C31641D2770C2A84D4FF68C157F0B8BFE0BDC1958D4310491";

    email = {
      username = "cgibreak@gmail.com";
      passwordFile = config.sops.secrets.attestation-server-email-password.path;
      host = "smtp.gmail.com";
      port = 465;
    };

    disableAccountCreation = true;
    nginx.enableACME = true;
  };
  sops.secrets.attestation-server-email-password = {};

  # For testing xrdesktop
#  services.xserver.desktopManager.gnome3.enable = true;
#  services.xserver.desktopManager.plasma5.enable = true;

  #programs.ccache.enable = true;
  programs.firejail.enable = true;

  #virtualisation.libvirtd.enable = true;
  #virtualisation.libvirtd.extraConfig = ''
  #  # Needed for virtio-fs
  #  memory_backing_dir = "/dev/shm/"
  #'';


#  services.mosquitto = {
#    enable = true;
#    # Not enabling SSL--so be sure to only access it over zerotier/wireguard
#    host = "0.0.0.0";
#    checkPasswords = true;
#    users.pixel3xl.hashedPassword = "";
#  };

  #services.jellyfin.enable = true;
  #services.netdata.enable = true; # Monitoring stuff

  virtualisation.docker.enable = true;
#  xdg.portal.enable = true;
#  services.flatpak.enable = true;
  security.tpm2 = {
    enable = true;
    tctiEnvironment.enable = true;
    #abrmd.enable = true;
  };

#  services.fwupd.enable = true;

#  boot.loader.systemd-boot.counters = {
#    enable = true;
#    tries = 2;
#  };

  #services.grocy = {
  #  enable = true;
  #  hostName = "grocy.daniel.fullmer.me";
  #};
  #services.nginx.virtualHosts."${config.services.grocy.hostName}".public = true;

  # services.tvheadend.enable = true;
  # hardware.firmware = [ pkgs.openelec-dvb-firmware ];

  services.nginx.statusPage = true; # for nginx exporter

  services.grafana.enable = true;
  services.grafana.settings.server.http_port = 3030;
  services.prometheus = {
    enable = true;
    retentionTime = "365d";
    globalConfig.scrape_interval = "15s";
    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [ { targets = [ "localhost:9100" ]; } ];
      }
#      {
#        job_name = "systemd";
#        static_configs = [ { targets = [ "localhost:9558" ]; } ];
#      }
      {
        job_name = "apcupsd";
        static_configs = [ { targets = [ "localhost:${builtins.toString config.services.prometheus.exporters.apcupsd.port}" ]; } ];
      }
    ];
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [
          "logind"
          "wifi"
          #"perf"
        ];
        extraFlags = [
          "--collector.textfile.directory=/var/lib/prometheus-node-exporter-text-files"
        ];
      };
      dnsmasq.enable = true;
      nginx.enable = true;
      #tor.enable = true;
      wireguard.enable = true;
      apcupsd.enable = true;
    };
  };

#  systemd.services.systemd-exporter = {
#    wantedBy = [ "multi-user.target" ];
#    serviceConfig.ExecStart = "${pkgs.systemd-exporter}/bin/systemd_exporter --web.listen-address=127.0.0.1:9558 --collector.enable-ip-accounting";
#  };

  systemd.tmpfiles.rules = [ "d /var/lib/prometheus-node-exporter-text-files 1755 root root 10d" ];

  system.activationScripts.node-exporter-system-version = ''
    (
      mkdir -p /var/lib/prometheus-node-exporter-text-files
      cd /var/lib/prometheus-node-exporter-text-files
      (
        echo -n "system_version ";
        readlink /nix/var/nix/profiles/system | cut -d- -f2
      ) > system-version.prom.next
      mv system-version.prom.next system-version.prom
    )
  '';

  systemd.services.prometheus-smartmon = let
    scripts = pkgs.fetchFromGitHub {
      owner = "prometheus-community";
      repo = "node-exporter-textfile-collector-scripts";
      rev = "57d05ce7ab752ec6795b452b1b660b736a32dcd5"; # 2020-08-04
      sha256 = "05pvi9kh35a2ixdm8i5bnkq992srd8b9ysb4cbxi684hl74q2444";
    };
  in {
    script = "${pkgs.python3}/bin/python ${scripts}/smartmon.py > /var/lib/prometheus-node-exporter-text-files/smartmon.prom";
    serviceConfig.Type = "oneshot";
    path = with pkgs; [ smartmontools ];
  };

  systemd.timers.prometheus-smartmon = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      Unit = "prometheus-smartmon.service";
      OnCalendar = "*:0/5"; # Every 5 minutes
    };
  };

  systemd.services.prometheus-nvme = let
    scripts = pkgs.stdenv.mkDerivation {
      name = "node-exporter-textfile-collector-scripts";
      src = pkgs.fetchFromGitHub {
        owner = "prometheus-community";
        repo = "node-exporter-textfile-collector-scripts";
        rev = "57d05ce7ab752ec6795b452b1b660b736a32dcd5"; # 2020-08-04
        sha256 = "05pvi9kh35a2ixdm8i5bnkq992srd8b9ysb4cbxi684hl74q2444";
      };
      buildInputs = [ pkgs.python3 ];
      installPhase = "mkdir -p $out/bin; cp * $out/bin/";
    };
  in {
    script = "${scripts}/bin/nvme_metrics.sh > /var/lib/prometheus-node-exporter-text-files/nvme.prom";
    serviceConfig.Type = "oneshot";
    path = with pkgs; [ nvme-cli gawk jq ];
  };

  systemd.timers.prometheus-nvme = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      Unit = "prometheus-nvme.service";
      OnCalendar = "*:0/5"; # Every 5 minutes
    };
  };

  # Listens for HTTPS on port 8443
  #services.unifi = {
  #  enable = true;
  #  openFirewall = false;
  #};
  #users.users.unifi.group = "unifi";
  #users.groups.unifi = {};
  #systemd.services.unifi.enable = false;
  networking.firewall.interfaces.enp68s0.allowedTCPPorts = [ 8080 8880 8843 6789 ];
  networking.firewall.interfaces.enp68s0.allowedUDPPorts = [ 3478 10001 ];

#  services.hledger-web = {
#    enable = true;
#    host = "127.0.0.1";
#    port = 5150;
#
#    journalFiles = [ "all.journal" ];
#  };

  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
  boot.kernelModules = [ "v4l2loopback" "snd-aloop" ];

  security.pam.loginLimits = [{
    domain = "*";
    type = "soft";
    item = "nofile";
    value = "4096";
  }];

  # For printer
  services.printing.enable = true;
  services.avahi.enable = true;

  services.avahi.allowInterfaces = [ "enp68s0" ];
  services.avahi.openFirewall = false; # Port 5353

  # Switch LG TV based on if CM storm keyboard is added/removed
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="2516", ATTRS{idProduct}=="0017", TAG+="systemd", ENV{SYSTEMD_ALIAS}="/sys/devices/cmstorm"
    ACTION=="remove", SUBSYSTEM=="usb", ATTRS{idVendor}=="2516", ATTRS{idProduct}=="0017", TAG+="systemd"
  '';
  sops.secrets.lgtv = {
    format = "binary";
    sopsFile = ../../secrets/lgtv_config;
  };

  systemd.services.cm-keyboard-attached = let
    lgtv = pkgs.runCommand "lgtv" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
      install -Dm755 ${./lgtv} $out/bin/lgtv
      wrapProgram $out/bin/lgtv --prefix PATH : ${lib.makeBinPath [ pkgs.websocat ]}
    '';
  in {
    wantedBy = [ "sys-devices-cmstorm.device" ];
    bindsTo = [ "sys-devices-cmstorm.device" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${lgtv}/bin/lgtv -c ${config.sops.secrets.lgtv.path} tv switchInput HDMI_1";
      ExecStop = "${lgtv}/bin/lgtv -c ${config.sops.secrets.lgtv.path} tv switchInput HDMI_2";
    };
  };

  services.fwupd.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  services.invidious = {
    enable = true;
    #package = pkgs.invidious.overrideAttrs (_: {
    #  version = "2.20240427";
    #  src = pkgs.fetchFromGitHub {
    #    owner = "iv-org";
    #    repo = "invidious";
    #    rev = "v2.20240427";
    #    hash = "sha256-P4Tz7spHfAopRmbw27x+7UAn2d9o7QWzBdFXYsnwIoQ=";
    #  };
    #  doCheck = false;
    #});
    domain = "invidious.daniel.fullmer.me";
    nginx.enable = true;
    settings.db.user = "invidious";
    sig-helper.enable = true;
  };

  programs.hyprland.enable = true;
  programs.hyprland.xwayland.enable = true;
  programs.xwayland.enable = true;

  programs.sway.enable = true;
}
