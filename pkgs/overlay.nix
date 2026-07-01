{ _config ? {} }: self: super:
let
  # Provide a default config if we dont' get it
  # This is probably too slow for comfort.
  config = if _config != {} then _config else (import (super.path + /nixos/lib/eval-config.nix) {
    modules = [
      ../modules/theme
      ../modules/programs.nix
      ../profiles/keyboard.nix
      ./custom-config.nix
    ];
  }).config;
in with super; {
  # Packages
  adapta-gtk-theme = adapta-gtk-theme.overrideAttrs (attrs: {
    configureFlags = attrs.configureFlags ++ (with config.theme.colors; [
      "--with-selection_color=#${base0C}"
      "--with-accent_color=#${base0D}"
      "--with-suggestion_color=#${base0D}"
      "--with-destruction_color=#${base08}"
      "--enable-parallel"
    ]);
    nativeBuildInputs = attrs.nativeBuildInputs ++ [ super.parallel ];
  });

  duplicity = duplicity.override { inherit (self) gnupg; };

  #emacs = callPackage ./emacs {};

  keyboard-firmware = callPackage ./keyboard-firmware { keymap=config.hardware.dactyl.keymap; };

  neovim = neovim.override {
    vimAlias = true;
    configure = {
      packages.myPlugins = {
        start = config.programs.vim.packages;
        opt = config.programs.vim.optionalPackages;
      };
      customRC = config.programs.vim.config;
      beforePlugins = config.programs.vim.configBeforePlugins;
    };
  };

  # Enabling cuda support via "config.cudaSupport = true;" causes Nix itself to be rebuilt since it depends on onetbb, which depends on hwloc, which 
  onetbb = super.onetbb.override {
    hwloc = super.hwloc.override {
      enableCuda = false;
    };
  };

  playmaker = python3Packages.callPackage ./playmaker {};

  st = (st.override {
    conf = (callPackage st/config.h.nix { theme=config.theme; });
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

  netgear-exporter = callPackage ./netgear-exporter {};
  systemd-exporter = callPackage ./systemd-exporter {};

#  fuse = fuse.overrideAttrs (attrs: {
#    # TODO: should be "attrs ++" or something like that but seems to get applied multiple times.
#    patches = [ ./libfuse/0001-Add-bcachefs-to-mountpoint-file-system-whitelist.patch ];
#  });

  ### jetson-ffmpegA
  jetson-ffmpeg-src = fetchFromGitHub {
    owner = "Keylost";
    repo = "jetson-ffmpeg";
    rev = "f0a52dfae54bdb2d42b72064d8be3e6b2f66244b";
    hash = "sha256-GACg3Ul2B9Z9ehd9W9nIuc4JyB2QdfvaC+4cfasH2Wo=";
  };
  libnvmpi = callPackage ./jetson-ffmpeg/libnvmpi.nix {};
  jetson-ffmpeg-patcher = import ./jetson-ffmpeg/ffmpeg-patcher.nix {
    inherit (self) jetson-ffmpeg-src libnvmpi;
    inherit (self.nvidia-jetpack) l4t-multimedia;
  };
  jetson-ffmpeg-6 = self.jetson-ffmpeg-patcher ffmpeg_6-headless;

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

  # This is for zws-specific stuff.
  # There is probably a more elegant way to do this.
  zis-arduino = arduino.overrideAttrs (attrs: {
    installPhase = attrs.installPhase + ''
      cp -r ${/home/danielrf/Sync/dev-box/monitors/zisworks/Arduino_ZWS}/avr/* $out/share/arduino/hardware/arduino/avr
    '';
  });
}
