{ config, pkgs, ... }:

{
  imports = [
      ../profiles/base.nix
      ../profiles/yubikey.nix
    ];

  services.nixosManual.enable = false;
}
