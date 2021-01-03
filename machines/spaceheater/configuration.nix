{ config, lib, pkgs, ... }:

{
  imports = [
    ../../profiles/base.nix
    ../../profiles/zerotier.nix
  ];

  networking.hostName = "spaceheater";
  networking.wireless.enable = true;

  system.autoUpgrade.enable = true;
}
