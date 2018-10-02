{ config, pkgs, lib, ... }:
{
  hardware.opengl.driSupport32Bit = true; # Needed for steam
  hardware.pulseaudio.support32Bit = true;
  hardware.steam-hardware.enable = true; # Provides udev rules for controller and HTC vive

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

  # Support for Steam play (Proton/wine)'s esync feature:
  # See https://github.com/zfigura/wine/blob/esync/README.esync<Paste>
  # https://github.com/ValveSoftware/Proton/blob/proton_3.7/PREREQS.md
  systemd.extraConfig = "DefaultLimitNOFILE=1048576";
  security.pam.loginLimits = [{
    domain = "*";
    type = "hard";
    item = "nofile";
    value = "1048576";
  }];
}
