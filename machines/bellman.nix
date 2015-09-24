{ config, lib, pkgs, ... }:

{
  imports = [
    ../profiles/base.nix
    ../profiles/syncthing.nix
    ../profiles/desktop.nix
    ../profiles/gaming.nix
#    ../profiles/academic.nix
    ../profiles/qemu-kvm.nix
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ata_piix" "usbhid" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/f6000fab-5ae0-4e96-b645-fcaa0f1ea781";
      fsType = "btrfs";
      options = "ssd,discard,compress=lzo,autodefrag";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/5071-EF38";
      fsType = "vfat";
    };
  };

  nix.maxJobs = 4;
  nix.buildCores = 8;

  boot.loader.gummiboot.enable = true;

  networking.hostName = "bellman"; # Define your hostname.
  networking.hostId = "f6bb12be";
}
