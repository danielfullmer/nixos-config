{ config, pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
    ../profiles/base.nix
    ../profiles/virtualbox-guest.nix
    ../profiles/yubikey.nix
    ../profiles/ssmtp.nix
    ../profiles/desktop.nix
    ../profiles/academic.nix
    ../profiles/homedir.nix
  ];

  boot.initrd.availableKernelModules = [ "ata_piix" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/584a34cb-f494-48d6-b308-eb4ae7d37c84";
      fsType = "ext4";
    };

  swapDevices = [ ];

  nix.maxJobs = 2;
  nix.buildCores = 4;

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "nyquist";
  networking.hostId = "d8ab690e";

  services.bitlbee.enable = true;
}
