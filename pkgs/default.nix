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
  theme = import ../modules/theme/defaultTheme.nix;

  # Packages

  adapta-gtk-theme = adapta-gtk-theme.overrideAttrs (attrs: {
    configureFlags = attrs.configureFlags ++ (with self.theme.colors; [
      "--with-selection_color=#${base0C}"
      "--with-accent_color=#${base0D}"
      "--with-suggestion_color=#${base0D}"
      "--with-destruction_color=#${base08}"
    ]);
  });

  dactyl-keyboard = callPackage ./dactyl-keyboard {};

  duplicity = duplicity.override { inherit (self) gnupg; };

  #emacs = callPackage ./emacs {};

  gmailieer = callPackage ./gmailieer {};

  neovim = neovim.override {
    vimAlias = true;
    configure = import ./neovim/config.nix { pkgs=self; theme=self.theme; };
  };

  surface-pro-firmware = callPackage ./surface-pro-firmware {};

  st = (st.override {
    conf = (callPackage st/config.h.nix {});
  });

  termite = (termite.override {
    configFile = writeText "termite-config" (import termite/config.nix { pkgs=self; theme=self.theme; });
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
