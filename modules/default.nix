{ config, pkgs, lib, ... } :
{
  imports = [
    ./ap.nix
    ./nginx-private.nix
    ./playmaker.nix
    ./programs.nix
    ./theme
  ];
}
