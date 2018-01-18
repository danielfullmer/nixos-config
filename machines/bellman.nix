{ config, lib, pkgs, ... }:

{
  imports = [
    ../profiles/base.nix
    ../profiles/extended.nix
    ../profiles/yubikey.nix
    ../profiles/syncthing.nix
    ../profiles/desktop/default.nix
    ../profiles/gaming.nix
    ../profiles/academic.nix
    ../profiles/postfix.nix
    ../profiles/gdrive.nix
  ];

  theme.base16Name = "chalk";

  system.stateVersion = "18.03";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_testing_bcachefs;
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.rtl8812au ];
  hardware.firmware = [ pkgs.firmwareLinuxNonfree ];  # For any other wifi firmware

  # Current partition status:
  # One bcachefs spanning 1x 500GB SSD and 2x 2Tb HDDs

  boot.initrd = {
    availableKernelModules = [
      "xhci_pci" "ehci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"
      "bcachefs"
    ];
  };

  fileSystems = {
    "/" = {
      device = "//dev/disk/by-partuuid/aff42536-c064-4c6a-a3af-a3bda7421dc5:/dev/disk/by-partuuid/2f5ccc7a-506e-4f51-973e-4058132e9052";
      fsType = "bcachefs";
    };
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

  services.xserver.deviceSection = ''
    Option "DRI3" "1"
  '';

  services.xserver.videoDrivers = [ "nvidia" "intel" ];

  services.redshift.enable = true;

  # For Seiki 4K monitor
  # TODO: Add modeline for 1080p at 120Hz
  fonts.fontconfig.dpi = 115;
  fonts.fontconfig.subpixel.rgba = "bgr";
  services.xserver.monitorSection = ''
    DisplaySize 698 393
  '';
  theme.fontSize = 12;

  theme.background = toString (pkgs.fetchurl {
    url = "https://4.bp.blogspot.com/-ttahA5YH_0M/WDcmRM-DoKI/AAAAAAACGlE/jBcAJ45T-twF5qoFR3TNQNyHTVGyGdCUACPcB/s0/Trip_in_Bled_Slovenia_4k.jpg";
    sha256 = "0fyw8ax2ci8fsj1zjxlb0pkm1knrx1qmq63mxzwp708qra9x4pq6";
  });


  services.hydra = {
    enable = true;
    hydraURL = "http://${config.networking.hostName}:3000/";
    notificationSender = "cgibreak@gmail.com";
    smtpHost = "${config.networking.hostName}";
    useSubstitutes = true;
    buildMachinesFiles = [ ../profiles/hydra-remote-machines ];
    # This is a deprecated option, but it's still used by NARInfo.pm
    extraConfig = "binary_cache_secret_key_file = /home/danielrf/nixos-config/secrets/bellman-nix-serve.sec";
  };

  #  systemd.user.services.gmailieer = {
  #    serviceConfig = {
  #      ExecStart = "${pkgs.gmailieer}/bin/gmi sync";
  #      Type = "oneshot";
  #      #WorkingDirectory = "/home/danielrf/mail";
  #    };
  #  };
  #
  #  systemd.user.timers.gmailieer = {
  #    wantedBy = [ "timers.target" ];
  #    timerConfig = {
  #      Unit = "gmailieer.service";
  #      OnCalendar = "*:0/3"; # Every 3 minutes
  #    };
  #  };

  environment.systemPackages = with pkgs; [ bcachefs-tools ];

  system.autoUpgrade.enable = true;
}
