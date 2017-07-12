with import <nixpkgs> {};

# See: nixpkgs/pkgs/misc/vim-plugins
# TL;DR
# build and execute this derivation

vimUtils.pluginnames2Nix {
  name = "local-plugin-names-to-nix";
  namefiles = [./plugin-names];
}
