{ pkgs }:

with pkgs;

let
inherit (vimUtils.override {inherit vim;}) rtpPath addRtp buildVimPlugin
  buildVimPluginFrom2Nix vimHelpTags;
in
{
  FastFold = buildVimPluginFrom2Nix { # created by nix#NixDerivation
    name = "FastFold-2017-04-27";
    src = fetchgit {
      url = "https://github.com/Konfekt/FastFold";
      rev = "680b65bf2455664f23a2feaa69ccd908d0ad94bc";
      sha256 = "02lziribfh869ck5xm560b11wi5awybvf1mk42lh2w89y6yb3mf1";
    };
    dependencies = [];

  };

  ale = buildVimPluginFrom2Nix { # created by nix#NixDerivation
    name = "ale-2017-07-12";
    src = fetchgit {
      url = "https://github.com/w0rp/ale";
      rev = "588595419739e3fec9cad921824e0e07aadb440d";
      sha256 = "15gk9hr900yjfh0rvyw9fill7qd89ck0qcp19l8wg8v4ja91x71c";
    };
    dependencies = [];

  };
}
