{ config, pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
    ../profiles/base.nix
    ../profiles/virtualbox-guest.nix
    ../profiles/academic.nix
  ];

  boot.initrd.availableKernelModules = [ "ata_piix" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/584a34cb-f494-48d6-b308-eb4ae7d37c84";
      fsType = "ext4";
    };

  swapDevices = [ ];

  #nix.maxJobs = 8;
  nix.buildCores = 0;

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "nyquist";

  networking.interfaces.zt0 = { ip4 = [ { address = "30.0.0.127"; prefixLength = 24; } ]; };
}
