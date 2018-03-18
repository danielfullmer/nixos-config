{ config, pkgs, lib, ... } :
{
  imports = [
    ./desktop.nix
    ./pam-u2f.nix
    ./theme
  ];
}
