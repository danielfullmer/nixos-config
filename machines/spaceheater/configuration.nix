{ config, lib, pkgs, ... }:

{
  imports = [
    ../../profiles/base.nix
    ../../profiles/dns.nix
    ../../profiles/zerotier.nix
  ];

  networking.hostName = "spaceheater";
  networking.wireless.enable = true;

  system.autoUpgrade.enable = true;
}
