{ pkgs ? import <nixpkgs> {},
  theme ? import ../modules/theme/defaultTheme.nix }:


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

  browserpass = callPackage ./browserpass {};

  duplicity = duplicity.override { inherit gnupg; };

  neovim = neovim.override { vimAlias = true; configure = (import ./neovim/config.nix { inherit pkgs theme; }); };

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

  my_qemu = lib.overrideDerivation qemu_kvm (attrs: {
      patches = [
     #   (fetchurl {
     #     name = "qemu-vcpu-affinity";
     #     url = https://github.com/justinvdk/qemu/commit/7d49a826417029df257604e62f7226b0cc4f5b7d.patch;
     #     sha256 = "07ah72rqdv6945d9gcv1xgcvbs7kx4qa3av9162sjsd1ws16shhc";
     #   })

        ./qemu/vcpu.patch
        ./qemu/input-linux-default-off.patch
      ] ++ attrs.patches;
    });

  vkcube = callPackage ./vkcube {};

  zcash = callPackage ./zcash {};
}
