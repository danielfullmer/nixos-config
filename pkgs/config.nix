{ pkgs ? import <nixpkgs> {},
  theme ? import ../modules/theme/defaultTheme.nix }:
{
  allowUnfree = true;
  packageOverrides = (pkgs: import ./default.nix { inherit pkgs theme; });
}
