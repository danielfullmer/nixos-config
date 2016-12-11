{ pkgs ? (import <nixpkgs> {}),
  theme ? (import ../themes) }:


with pkgs; {
### Example to patch a derivation
#  zerotierone = pkgs.lib.overrideDerivation pkgs.zerotierone (attrs: {
#    patches = [
#      (pkgs.fetchurl {
#        url = "https://github.com/zerotier/ZeroTierOne/commit/039790cf267cb67a5130fb82caf97998d8b0959e.patch";
#        sha256 = "1n93gvi3d3jsb84k496rhs61ycq5wih1yn47wiz2jwfd83bryarj";
#      })
#    ];
#  });

  neofetch = callPackage ./neofetch {};

  # TODO: If I override this with the same name there is an issue with the neovim-qt derivation
  nvim = neovim.override { vimAlias = true; configure = (import ./neovim/config.nix { inherit pkgs; }); };

  surface-pro-firmware = callPackage ./surface-pro-firmware {};

  st = (st.override {
    conf = (import st/config.h.nix { inherit theme; });
  });

  termite = (termite.override {
    configFile = pkgs.writeTextFile {
      name = "termite-config";
      text = (import termite/config.nix { inherit pkgs theme; });
    };
  });

  zcash = callPackage ./zcash {};
}
