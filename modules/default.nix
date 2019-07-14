{ config, pkgs, lib, ... } :
{
  imports = [
    ./programs.nix
    ./theme
    ./secrets.nix

    ./attestation-server.nix
    ./playmaker.nix
  ];
}
