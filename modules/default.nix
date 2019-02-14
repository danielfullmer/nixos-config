{ config, pkgs, lib, ... } :
{
  imports = [
    ./desktop.nix
    ./theme
  ];
}
