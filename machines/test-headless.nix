{ config, pkgs, ... }:

{
  imports = [
      ../profiles/base.nix
      ../profiles/homedir.nix
      ../profiles/yubikey.nix
    ];

  services.nixosManual.enable = false;
}
