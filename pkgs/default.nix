{ pkgs ? (import <nixpkgs>),
  theme ? (import ../themes)
}:

{
### Example to patch a derivation
#  zerotierone = pkgs.lib.overrideDerivation pkgs.zerotierone (attrs: {
#    patches = [
#      (pkgs.fetchurl {
#        url = "https://github.com/zerotier/ZeroTierOne/commit/039790cf267cb67a5130fb82caf97998d8b0959e.patch";
#        sha256 = "1n93gvi3d3jsb84k496rhs61ycq5wih1yn47wiz2jwfd83bryarj";
#      })
#    ];
#  });

  # TODO: If I override this with the same name there is an issue with the neovim-qt derivation
  nvim = pkgs.neovim.override { vimAlias = true; configure = (import ./neovim/config.nix { inherit pkgs; }); };

  st = (pkgs.st.override {
    conf = (import st/config.h.nix { inherit pkgs theme; });
  });

  termite = (pkgs.termite.override {
    configFile = (import termite/config.nix { inherit theme; });
  });

  zcash = pkgs.callPackage ./zcash {};
}
