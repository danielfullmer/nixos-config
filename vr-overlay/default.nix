self: super: {
  gulkan = super.callPackage ./gulkan.nix {};
  gxr = super.callPackage ./gxr.nix {};
  kwin-effect-xrdesktop = super.libsForQt5.callPackage ./kwin-effect-xrdesktop.nix {};
  libinputsynth = super.callPackage ./libinputsynth.nix {};
  openvr = super.callPackage ./openvr.nix {};
  xrdesktop = super.callPackage ./xrdesktop.nix {};
}
