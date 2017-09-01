{ pkgs ? import <nixpkgs> {},
  theme ? import ../modules/theme/defaultTheme.nix }:


rec {
### Example to patch a derivation
#  zerotierone = pkgs.zerotierone.overrideAttrs (attrs: {
#    patches = [
#      (pkgs.fetchurl {
#        url = "https://github.com/zerotier/ZeroTierOne/commit/039790cf267cb67a5130fb82caf97998d8b0959e.patch";
#        sha256 = "1n93gvi3d3jsb84k496rhs61ycq5wih1yn47wiz2jwfd83bryarj";
#      })
#    ];
#  });

  dactyl-keyboard = pkgs.callPackage ./dactyl-keyboard {};

  duplicity = pkgs.duplicity.override { inherit (pkgs) gnupg; };

  emacs = pkgs.callPackage ./emacs {};

  neovim = pkgs.neovim.override { vimAlias = true; configure = (import ./neovim/config.nix { inherit pkgs theme; }); };

  surface-pro-firmware = pkgs.callPackage ./surface-pro-firmware {};

  st = (pkgs.st.override {
    conf = (import st/config.h.nix { inherit theme; });
  });

  termite = (pkgs.termite.override {
    configFile = pkgs.writeText "termite-config" (import termite/config.nix { inherit pkgs theme; });
  });

  my_qemu = pkgs.qemu_kvm.overrideAttrs (attrs: {
    patches = [
   #   (fetchurl {
   #     name = "qemu-vcpu-affinity";
   #     url = https://github.com/justinvdk/qemu/commit/7d49a826417029df257604e62f7226b0cc4f5b7d.patch;
   #     sha256 = "07ah72rqdv6945d9gcv1xgcvbs7kx4qa3av9162sjsd1ws16shhc";
   #   })

      ./qemu/input-linux-default-off.patch

   # I use libvirtd to set thread affinity instead of this patch
   #  ./qemu/vcpu.patch
    ] ++ attrs.patches;
  });

  vkcube = pkgs.callPackage ./vkcube {};

  xcompose = pkgs.callPackage ./xcompose {};
}
