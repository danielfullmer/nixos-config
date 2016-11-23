{
  allowUnfree = true;
  packageOverrides = (pkgs: import ./default.nix { inherit pkgs; });
}
