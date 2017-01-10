{ pkgs }:

with pkgs;

let
inherit (vimUtils.override {inherit vim;}) rtpPath addRtp buildVimPlugin
  buildVimPluginFrom2Nix vimHelpTags;
in
{
  # See: nixpkgs/pkgs/misc/vim-plugins
  # TL;DR
  # Open update-plugins.nix in vim
  # Run :source %

}
