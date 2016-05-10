{ pkgs }:

rec {
  base16 = pkgs.callPackage ./base16.nix {};
}
