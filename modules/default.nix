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
      rev = "d411dd7194b07b6f07430f8aa1e04187e85d7a4c";
      #sha256 = "";
    }) + /nixos)
    ./playmaker.nix
  ];
}
