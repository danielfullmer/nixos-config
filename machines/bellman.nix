{ config, lib, pkgs, ... }:

{
  imports = [
    ../profiles/base.nix
    ../profiles/desktop.nix
    ../profiles/gaming.nix
    ../profiles/academic.nix
    ../profiles/qemu-kvm.nix
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ata_piix" "usbhid" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/bb2758a7-77c4-43bb-ba9b-53dced8160bd";
      fsType = "ext4";
    };
    "/home" = {
      device = "/dev/disk/by-uuid/fab9b0c5-521e-4b53-8433-41e51ddc238d";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/6dc76b28-47e2-46b1-aa24-639fd5d56661";
      fsType = "ext4";
    };
  };


  swapDevices =
    [ { device = "/dev/disk/by-uuid/f728dfb8-dfe8-4c0e-afbb-dca0b4c3b49a"; }
    ];

  nix.maxJobs = 4;
  nix.buildCores = 8;

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "bellman"; # Define your hostname.
  networking.hostId = "f6bb12be";
}
