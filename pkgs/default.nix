self: super: with super; {
### Example to patch a derivation
#  zerotierone = pkgs.zerotierone.overrideAttrs (attrs: {
#    patches = [
#      (fetchurl {
#        url = "https://github.com/zerotier/ZeroTierOne/commit/039790cf267cb67a5130fb82caf97998d8b0959e.patch";
#        sha256 = "1n93gvi3d3jsb84k496rhs61ycq5wih1yn47wiz2jwfd83bryarj";
#      })
#    ];
#  });

  # Local stuff
  # "theme" by itself conflicts with some stuff in nixpkgs
  localtheme = import ../modules/theme/defaultTheme.nix;

  # Packages

  adapta-gtk-theme = adapta-gtk-theme.overrideAttrs (attrs: {
    configureFlags = attrs.configureFlags ++ (with self.localtheme.colors; [
      "--with-selection_color=#${base0C}"
      "--with-accent_color=#${base0D}"
      "--with-suggestion_color=#${base0D}"
      "--with-destruction_color=#${base08}"
    ]);
  });

  bcachefs-tools = bcachefs-tools.overrideAttrs (attrs: {
    src = fetchgit {
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

  linux_testing_bcachefs = callPackage <nixpkgs/pkgs/os-specific/linux/kernel/linux-testing-bcachefs.nix> {
    argsOverride.src = fetchgit {
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

  dactyl-keyboard = callPackage ./dactyl-keyboard {};

  duplicity = duplicity.override { inherit (self) gnupg; };

  #emacs = callPackage ./emacs {};

  neovim = neovim.override {
    vimAlias = true;
    configure = import ./neovim/config.nix { pkgs=self; theme=self.localtheme; };
  };

  #papis = callPackage ./papis {};

  surface-pro-firmware = callPackage ./surface-pro-firmware {};

  st = (st.override {
    conf = (callPackage st/config.h.nix { theme=self.localtheme; });
  });

  termite = (termite.override {
    configFile = writeText "termite-config" (import termite/config.nix { pkgs=self; theme=self.localtheme; });
  });

  my_qemu = qemu_kvm.overrideAttrs (attrs: {
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

  vkcube = callPackage ./vkcube {};

  xcompose = callPackage ./xcompose {};

  #### Environments ####

  pythonEnv = (python3.buildEnv.override {
    extraLibs = with self.python3Packages; [
      jupyter
      bpython
      numpy
      sympy
      matplotlib
      seaborn
      pandas
    ];
    ignoreCollisions = true;
  });
}
