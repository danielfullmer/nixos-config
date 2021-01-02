{ config, pkgs, lib, ... } :
{
  imports = [
    ./ap.nix
    ./programs.nix
    ./theme

#    /home/danielrf/robotnix/nixos
    ((builtins.fetchGit {
      url = "https://github.com/danielfullmer/robotnix";
      rev = "5d75d777e2710c2f990d3ab4611df3115fed3510";
      #sha256 = "";
    }) + /nixos)
    ./playmaker.nix
  ];
}
