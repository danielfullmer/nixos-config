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

  bcachefs-tools = pkgs.bcachefs-tools.overrideAttrs (attrs: {
    src = pkgs.fetchgit {
      url = "https://evilpiepirate.org/git/bcachefs-tools.git";
      rev = "bf8c59996b3fb2a940827d12438a9e18eca6db4c";
      sha256 = "0n1jlkfksl83igx90fmafdjpfdjv6hyyz3mcm2fv9mknd4qiz27d";
    };

    # Makefile uses "git ls-files". This fixes that
    preBuild = ''
      makeFlagsArray=(SRCS="$(find -iname '*.c')")
    '';

    patches = [ ./bcachefs/bcachefs-tools.patch ];
  });

  linux_testing_bcachefs = pkgs.callPackage <nixpkgs/pkgs/os-specific/linux/kernel/linux-testing-bcachefs.nix> {
    argsOverride.src = pkgs.fetchgit {
      url = "https://evilpiepirate.org/git/bcachefs.git";
      rev = "e82e65627960a46945b78a5e5e946b23b8f08972";
      sha256 = "131nmrl5iqhh00mnnja4ixk1fb8bhx1zv9pa9w2gj71a47pr311v";
    };

    kernelPatches = with pkgs.kernelPatches;
      [ bridge_stp_helper
        p9_fixes
        # See pkgs/os-specific/linux/kernel/cpu-cgroup-v2-patches/README.md
        # when adding a new linux version
        cpu-cgroup-v2."4.11"
        modinst_arg_list_too_long
        { name = "bcachefs-fix"; patch = ./bcachefs/bcachefs.patch; }
      ];
  };

  dactyl-keyboard = pkgs.callPackage ./dactyl-keyboard {};

  duplicity = pkgs.duplicity.override { inherit (pkgs) gnupg; };

  #emacs = pkgs.callPackage ./emacs {};

  gmailieer = pkgs.callPackage ./gmailieer {};

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
