{ config, pkgs, ... }:

{
  imports = [
    ../profiles/base.nix
    ../profile/interactive.nix
    ../profiles/yubikey.nix
  ];

  services.nixosManual.enable = false;
}
