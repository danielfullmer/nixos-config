{ config, lib, pkgs, ... }:

{
  imports = [
    ../../profiles/base.nix
  ];

  networking.hostName = "spaceheater";
  networking.wireless.enable = true;

  system.autoUpgrade.enable = true;
}
