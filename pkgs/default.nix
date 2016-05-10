{ pkgs }:

rec {
  base16 = pkgs.callPackage ./base16.nix {};

  # Fix an issue with newer versions of gcc
  zerotierone = pkgs.lib.overrideDerivation pkgs.zerotierone (attrs: {
    patches = [
      (pkgs.fetchurl {
        url = "https://github.com/zerotier/ZeroTierOne/commit/039790cf267cb67a5130fb82caf97998d8b0959e.patch";
        sha256 = "1n93gvi3d3jsb84k496rhs61ycq5wih1yn47wiz2jwfd83bryarj";
      })
    ];
  });
}
