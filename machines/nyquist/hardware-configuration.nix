{ config, pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
  ];

  system.stateVersion = "17.03";

  boot.initrd.availableKernelModules = [ "ata_piix" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  boot.initrd.luks.devices = {
    nyquist-root = {
      device = "/dev/disk/by-uuid/98d7c646-dc01-4683-bde8-eba6cb301ab9";
      preLVM = true;
      allowDiscards = true;
    };
  };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/584a34cb-f494-48d6-b308-eb4ae7d37c84";
      fsType = "ext4";
      options = [ "discard" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/F499-DA70";
      fsType = "vfat";
    };

  fileSystems."/drf36" = {
    device = "drf36";
    fsType = "vboxsf";
  };

  swapDevices = [ ];

  nix.maxJobs = 6;
  nix.buildCores = 6;

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  virtualisation.virtualbox.guest.enable = true;
}
