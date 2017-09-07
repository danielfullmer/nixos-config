{ config, lib, pkgs, ... }:

{
  imports = [
    ./bellman.nix
  ];

  ### Status as of 2017-05-27 for 390x
  # Boots correctly
  # Need a version with the recent multiview commits reverted (e.g. cb208d7...)
  # See: https://bugs.freedesktop.org/show_bug.cgi?id=102571
  # Vive needs to be plugged into USB 2
  # Detects basestation, controllers, headset.
  # Needs a version of steam with extra dependencies (see nixpkgs branch)

  boot.kernelParams = [
    "radeon.cik_support=0"
    "radeaon.si_support=0"
    "amdgpu.cik_support=1"
    "amdgpu.si_support=1"
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  ### XXX: Mesa-git stuff from github.com/corngood/nixos-mesa-git
  nixpkgs.config.packageOverrides = pkgs: with pkgs.stdenv.lib;
  let
    mesa = ((pkgs.mesa_noglu.override {
      # this is probably the default by now in nixpkgs
      # without it you get opengl 2.1 contexts
      enableTextureFloats = true;
      enableRadv = true; # this isn't really needed when setting 'vulkanDrivers'
      galliumDrivers = [ "radeonsi" ];
      driDrivers = [ "radeon" ];
      vulkanDrivers = [ "radeon" ];
    }).overrideAttrs(attrs: {
      name = "mesa-steamvr-git";
      src = pkgs.fetchFromGitHub {
        owner = "mesa3d";
        repo = "mesa";
        rev = "64164a1313fcdf1084b0f8a9499165ee22a13aa7";
        sha256 = "0bdblw2xh0vm2gycxzyqy5yzakaq1rin9xlm68x89l2wp58cxs5j";
      };
      # this nixpkg version of this patch didn't apply cleanly
      # we should probably find a less fragile way of doing this
      patches = [ ./mesa-symlink-drivers.patch ];
      buildInputs = attrs.buildInputs ++ [ pkgs.wayland-protocols ];
      nativeBuildInputs = attrs.nativeBuildInputs ++ [ pkgs.bison pkgs.flex pkgs.pythonPackages.Mako ];
    }));

  in {
    xorg = pkgs.xorg // {
      xorgserver = pkgs.xorg.xorgserver.override {
        mesa = mesa;
      };
      xf86videoamdgpu = pkgs.xorg.xf86videoamdgpu.override {
        mesa = mesa;
      };
    };
    mesa_drivers = mesa.drivers;
  };

  hardware.opengl.s3tcSupport = true; # use patented texture compressor

  environment.systemPackages = [ pkgs.vulkan-loader ];
}
