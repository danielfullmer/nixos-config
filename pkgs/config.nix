{ pkgs ? import <nixpkgs>,
  theme ? import ../modules/defaultTheme.nix }:
{
  allowUnfree = true;
  packageOverrides = (pkgs: import ./default.nix { inherit pkgs theme; });
}
