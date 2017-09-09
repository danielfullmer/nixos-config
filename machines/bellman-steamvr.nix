{ config, lib, pkgs, ... }:

{
  imports = [
    ./bellman.nix
  ];

  ### Status as of 2017-09-09 for 390x
  # Boots correctly
  # Vive needs to be plugged into USB 2
  # Detects basestation, controllers, headset.
  # Needs a version of steam with extra dependencies (see nixpkgs branch)
  # Runs correctly--vrcompositor outputs to a window on the desktop
  # But HTC vive does not display any image. :(

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
        rev = "ec8ed2f2779c30863f7478b8f5ad9654abbff346";
        sha256 = "121m8q4d72897vcgrlg8gaxmy0fs8f7jsgckwf2ybhf9c47ag4g1";
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
