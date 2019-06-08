{ config, pkgs, lib, ... } :
{
  imports = [
    ./programs.nix
    ./theme
    ./secrets.nix

    ./playmaker.nix
  ];
}
