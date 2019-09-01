{ config, lib, pkgs, ... }:

{
  imports = [
    ../profiles/base.nix
  ];

  theme.base16Name = "irblack";

  networking.hostName = "spaceheater";
  networking.wireless.enable = true;

  system.autoUpgrade.enable = true;
}
