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

  FastFold = buildVimPluginFrom2Nix { # created by nix#NixDerivation
    name = "FastFold-2017-01-29";
    src = fetchgit {
      url = "git://github.com/Konfekt/FastFold";
      rev = "12e60714c2307c2379fd8498912aac23dc037474";
      sha256 = "04gy5abrcdas0il543y6zzzfrjccjqm6wxixb6s3wd1q4qszs47a";
    };
    dependencies = [];

  };
}
