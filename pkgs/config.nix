{ pkgs ? import <nixpkgs>,
  theme ? import ../themes }:
{
  allowUnfree = true;
  packageOverrides = (pkgs: import ./default.nix { inherit pkgs theme; });
}
