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
      rev = "b059acfc8fb0fe0b02379812f51a914a8e99bdec";
      #sha256 = "";
    }) + /nixos)
    ./playmaker.nix
  ];
}
