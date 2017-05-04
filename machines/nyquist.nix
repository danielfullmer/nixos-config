{ config, pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
    ../profiles/base.nix
    ../profiles/yubikey.nix
    ../profiles/ssmtp.nix
    ../profiles/desktop/default.nix
    ../profiles/academic.nix
    ../profiles/gdrive.nix
    ../profiles/homedir.nix
  ];

  boot.initrd.availableKernelModules = [ "ata_piix" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/584a34cb-f494-48d6-b308-eb4ae7d37c84";
      fsType = "ext4";
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

  networking.hostName = "nyquist";
  networking.hostId = "d8ab690e";

  virtualisation.virtualbox.guest.enable = true;

  services.bitlbee.enable = true;
  services.plex.enable = true;
}
