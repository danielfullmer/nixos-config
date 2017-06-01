{ config, lib, pkgs, ... }:

{
  imports = [
    ../profiles/base.nix
    ../profiles/yubikey.nix
    ../profiles/syncthing.nix
    ../profiles/desktop/default.nix
    ../profiles/gaming.nix
    ../profiles/academic.nix
    ../profiles/postfix.nix
    ../profiles/gdrive.nix
    ../profiles/homedir.nix
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ata_piix" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ "bcache" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.rtl8812au ];
  hardware.enableAllFirmware = true;  # For any other wifi firmware

  # NOTE: Using bcache + LVM
  # bcache on: ata-ST2000DM006-2DM164_W4Z4BH2E-part2 and ata-WDC_WD5000AAKS-22TMA0_WD-WCAPW3279067
  # bcache ssd is: ata-OCZ-AGILITY4_OCZ-CS8UXT0MD692SSR2
  # LVM on top of each of those, combined into a single volume group
  # Try to move windows off of faster 500gb SSD, and then switch bcache and swap to that one.
  fileSystems = {
    "/" = {
      device = "/dev/mapper/VolGroup0-main";
      fsType = "btrfs";
      options = [ "compress" ];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/3AF1-2802";
      fsType = "vfat";
    };
  };

  swapDevices = [ { device = "/dev/mapper/VolGroup0-swap"; } ];

  nix.maxJobs = 2;
  nix.buildCores = 4;

  boot.loader.systemd-boot.enable = true;

  networking.hostName = "bellman"; # Define your hostname.
  networking.hostId = "f6bb12be";
  #networking.wireless.enable = true;
  networking.networkmanager.enable = true;

  services.acpid.enable = true;

  # Use AMDGPU support.
  boot.kernelParams = [ "amdgpu.exp_hw_support=1" "amdgpu.audio=0" ];
  services.xserver.videoDrivers = [ "amdgpu" ];

  services.xserver.deviceSection = ''
    Option "DRI3" "1"
    Option "TearFree" "on"
  '';

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
  };

  services.nix-serve = {
    enable = true;
    secretKeyFile = "/home/danielrf/nixos-config/secrets/bellman-nix-serve.sec";
  };
}
