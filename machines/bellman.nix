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
  hardware.enableAllFirmware = true;  # For any other wifi firmware

  boot.kernelPatches = [ {
    name = "enable-latencytop";
    patch = "";
    extraConfig = ''
      SCHEDSTATS y
      LATENCYTOP y
    '';
  } ];

  # NOTE: Using bcache + LVM
  # bcache on: ata-ST2000DM006-2DM164_W4Z4BH2E-part2 and ata-WDC_WD5000AAKS-22TMA0_WD-WCAPW3279067
  # bcache ssd is: ata-OCZ-AGILITY4_OCZ-CS8UXT0MD692SSR2
  # LVM on top of each of those, combined into a single volume group
  # Try to move windows off of faster 500gb SSD, and then switch bcache and swap to that one.

  boot.initrd = {
    availableKernelModules = [
      "xhci_pci" "ehci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"

      # LUKS stuff, not sure how much is needed
      "aes_x86_64" "aesni_intel" "af_alg" "algif_skcipher" "cbc" "cryptd" "crypto_simd"
      "dm_crypt" "ecb" "gf128mul" "glue_helper" "xts"

      "bcachefs"
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
        device = "/dev/disk/by-uuid/c2691d0f-071e-46ab-897c-555f9164322d";
        keyFile = "/dev/mapper/luks-key";
        keyFileSize = 4096;
        preLVM = false;
      }
      { name = "hd2";
        device = "/dev/disk/by-uuid/d9222f0e-4180-4896-83e7-347110fda931";
        keyFile = "/dev/mapper/luks-key";
        keyFileSize = 4096;
        preLVM = false;
      }
      { name = "ssd";
        device = "/dev/disk/by-uuid/bfe14fae-1e45-4022-8ee2-8ed1d5b200c3";
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
      # Extra / at the beginning of this device is a hack to ensure stage-1
      # recognizes this as a "pseudodevice" and doesn't wait around for it to appear
      device = "//dev/mapper/ssd:/dev/mapper/hd1:/dev/mapper/hd2";
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

  systemd.services.gmailieer = {
    serviceConfig = {
      ExecStart = "${pkgs.gmailieer}/bin/gmi sync";
      Type = "oneshot";
      User = "danielrf";
      Group = "danielrf";
      WorkingDirectory = "/home/danielrf/mail";
    };
  };

  systemd.timers.gmailieer = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      Unit = "gmailieer.service";
      OnCalendar = "*:0/3"; # Every 3 minutes
    };
  };

  environment.systemPackages = with pkgs; [ bcachefs-tools ];
}
