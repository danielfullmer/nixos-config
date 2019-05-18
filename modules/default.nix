{ config, pkgs, lib, ... } :
{
  imports = [
    ./programs.nix
    ./theme

    ./playmaker.nix
  ];
}
