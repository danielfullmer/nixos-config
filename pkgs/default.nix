{ config ? {
    # Provide some default options to use below in case we aren't getting the config from the nixos config
    theme = import ../modules/theme/defaultTheme.nix;
  }
}:
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

  # Packages

  adapta-gtk-theme = adapta-gtk-theme.overrideAttrs (attrs: {
    configureFlags = attrs.configureFlags ++ (with config.theme.colors; [
      "--with-selection_color=#${base0C}"
      "--with-accent_color=#${base0D}"
      "--with-suggestion_color=#${base0D}"
      "--with-destruction_color=#${base08}"
    ]);
  });

  keyboard-firmware = callPackage ./keyboard-firmware {};

  duplicity = duplicity.override { inherit (self) gnupg; };

  # Dmenu 4.9 segfaults on entering text. Pick up a slightly later version with this fixed.
  dmenu = dmenu.overrideAttrs (attrs: {
    src = fetchgit {
      url = https://git.suckless.org/dmenu;
      rev = "db6093f6ec1bb884f7540f2512935b5254750b30";
      sha256 = "9eb21eb1cb7f488876d34648e1ab22598d70729496f837c60595e066fa0d19bf";
    };
  });

  #emacs = callPackage ./emacs {};

  neovim = neovim.override {
    vimAlias = true;
    configure = import ./neovim/config.nix { pkgs=self; theme=config.theme; };
  };

  st = (st.override {
    conf = (callPackage st/config.h.nix { theme=config.theme; });
  });

  termite = (termite.override {
    configFile = writeText "termite-config" (import termite/config.nix { pkgs=self; theme=config.theme; });
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

  xcompose = callPackage ./xcompose {};

  fuse = super.fuse.overrideAttrs (attrs: {
    patches = attrs.patches ++ [ ./libfuse/0001-Add-bcachefs-to-mountpoint-file-system-whitelist.patch ];
  });

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
