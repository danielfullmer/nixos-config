{ config, lib, pkgs, ... }:

{
  imports = [
    ../../profiles/personal.nix
    ../../profiles/dns.nix
    #../../profiles/zerotier.nix
  ];

  networking.hostName = "viterbi";

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  # This partition is on the sd card.
  # TODO: Once we figure out how to get uboot to boot from the nvme drive,
  # switch to that, instead.
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/ESP";
    fsType = "vfat";
  };
}
