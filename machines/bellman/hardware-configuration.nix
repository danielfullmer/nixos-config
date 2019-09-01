{ config, pkgs, lib, ... }:

{
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
  # However, vdevs can't be removed from a pool if they have different ashift values, so just use ashift=12 everywhere.
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
}
