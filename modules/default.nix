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
      rev = "c555a89b1740887c2fbd0c100b8589fd9b03a908";
      #sha256 = "";
    }) + /nixos)
    ./playmaker.nix
  ];
}
