{ config, pkgs, lib, ... }:
{
  programs.steam.enable = true;
  hardware.steam-hardware.enable = true; # Provides udev rules for controller, HTC vive, and Valve Index

  hardware.opengl.driSupport32Bit = true; # Needed for steam
  hardware.pulseaudio.support32Bit = true;

#  nixpkgs.overlays = [ (self: super: {
#    steam = super.steam.override (
#      { #nativeOnly = true; # Otherwise the qt libraries below try to pull in steam runtime libs (which are too old): https://github.com/NixOS/nixpkgs/issues/32881#issuecomment-426513878
#        # Extra deps are for steamvr support
#        extraPkgs = p: with p; [
#          dbus_daemon
#          # Libraries needed by vrmonitor. While there is an "extraLibraries"
#          # argument, it puts things in multiPkgs instead of targetPkgs.
#          # multiPkgs makes a copy for each support arch (here 32 and 64-bit),
#          # but we only care about 64-bit and don't want to recompile qtbase
#          #qt5.qtbase qt5.qtmultimedia
#        ];
#      });
#  }) ];
#  nixpkgs.config.allowBroken = true;

}
