{ config, pkgs, lib, ... }:
{
  hardware.opengl.driSupport32Bit = true; # Needed for steam
  hardware.pulseaudio.support32Bit = true;
  hardware.steam-hardware.enable = true; # Provides udev rules for controller, HTC vive, and Valve Index

  services.xserver.modules = [ pkgs.xlibs.xf86inputjoystick ];

  environment.systemPackages = (with pkgs; [
    steam
    steam-run
  ]);

  nixpkgs.overlays = [ (self: super: {
    steam = super.steam.override (
      { #nativeOnly = true;
        # Extra deps are for steamvr support
        extraPkgs = p: with p; [ usbutils lsb-release procps dbus_daemon ];
      });
  }) ];
}
