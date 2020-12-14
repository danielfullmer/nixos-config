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
      rev = "2b7b19a601e3ac2199f55f217584c9fc0f537d66";
      #sha256 = "";
    }) + /nixos)
    ./playmaker.nix
  ];
}
