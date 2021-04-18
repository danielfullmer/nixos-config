{ config, pkgs, lib, ... } :
{
  imports = [
    ./ap.nix
    ./nginx-private.nix
    ./nvidia-vgpu.nix
    ./playmaker.nix
    ./programs.nix
    ./theme
  ];
}
