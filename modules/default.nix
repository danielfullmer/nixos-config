{ config, pkgs, lib, ... } :
{
  imports = [
    ./ap.nix
    ./programs.nix
    ./theme
    ./secrets.nix

#    /home/danielrf/robotnix/nixos
    ((builtins.fetchGit {
      url = "https://github.com/danielfullmer/robotnix";
      rev = "3d379babfdcb739835f5fb06bc79c2c03f4c801d";
      #sha256 = "";
    }) + /nixos)
    ./playmaker.nix
  ];
}
