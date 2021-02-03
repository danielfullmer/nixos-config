{ config, pkgs, lib, ... } :
{
  imports = [
    ./ap.nix
    ./programs.nix
    ./theme
    ./playmaker.nix
  ];
}
