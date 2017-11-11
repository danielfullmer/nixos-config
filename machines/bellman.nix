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

  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.rtl8812au ];
  hardware.enableAllFirmware = true;  # For any other wifi firmware

  boot.kernelPatches = [ {
    name = "enable-latencytop";
    patch = "";
    extraConfig = ''
      SCHEDSTATS y
      LATENCYTOP y
    '';
  } ];

  # Current partition status:
  # All drives backed by bcache
  # All drives have a main LUKS partition
  # BTRFS directly on top of on two of those drives
  # LVM on the other, with windows disk on top

  boot.initrd = {
    kernelModules = [ "bcache" ];
    availableKernelModules = [
      "xhci_pci" "ehci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"

      # LUKS stuff, not sure how much is needed
      "aes_x86_64" "aesni_intel" "af_alg" "algif_skcipher" "cbc" "cryptd" "crypto_simd"
      "dm_crypt" "ecb" "gf128mul" "glue_helper" "xts"
    ];

    # To avoid slow boot times, luksAddKey was done with --iter-time 100
    # luks-key is in first slot in remaining devices for speed as well
    luks.devices = [
      # See: https://github.com/NixOS/nixpkgs/issues/24386
      { name = "luks-key"; # No encrypted filesystem, just an encrypted 4096-bit key
        device = "/dev/disk/by-uuid/0727144d-70bf-4f4b-bff1-b5601ef833cc";
        preLVM = true; # Ensure the vault device is mounted first
      }
      { name = "hd1";
        device = "/dev/disk/by-uuid/63e731c3-a339-4df3-b9d3-acbb818e7533";
        keyFile = "/dev/mapper/luks-key";
        keyFileSize = 4096;
        preLVM = false;
      }
      { name = "hd2";
        device = "/dev/disk/by-uuid/b93b6108-7fc6-47dc-8279-96476bfba9d4";
        keyFile = "/dev/mapper/luks-key";
        keyFileSize = 4096;
        preLVM = false;
      }
      { name = "hd3";
        device = "/dev/disk/by-uuid/19aae242-c0ca-4486-bce8-080befd075cd";
        keyFile = "/dev/mapper/luks-key";
        keyFileSize = 4096;
        preLVM = false;
      }
    ];

    postDeviceCommands = lib.mkAfter ''
      cryptsetup luksClose /dev/mapper/luks-key
    '';
  };

  fileSystems = {
    "/" = {
      device = "/dev/mapper/hd2";
      fsType = "btrfs";
      options = [ "device=/dev/mapper/hd3" ];
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

  #services.xserver.videoDrivers = [ "intel" "nvidia" ];
  services.xserver.videoDrivers = [ "intel" ];

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

  system.autoUpgrade.enable = true;
}
