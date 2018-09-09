{ config, pkgs, lib, ... }:
{
  hardware.opengl.driSupport32Bit = true; # Needed for steam
  hardware.pulseaudio.support32Bit = true;

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


  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "steamvr-udev-rules";
      destination = "/etc/udev/rules.d/60-steamvr.rules"; # Need to have a number before 73-seat-late.rules where uaccess is actually activated
      text = ''
        # HTC Vive HID Sensor naming and permissioning
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0bb4", ATTRS{idProduct}=="2c87", TAG+="uaccess"
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="28de", ATTRS{idProduct}=="2101", TAG+="uaccess"
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="28de", ATTRS{idProduct}=="2000", TAG+="uaccess"
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="28de", ATTRS{idProduct}=="1043", TAG+="uaccess"
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="28de", ATTRS{idProduct}=="2050", TAG+="uaccess"
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="28de", ATTRS{idProduct}=="2011", TAG+="uaccess"
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="28de", ATTRS{idProduct}=="2012", TAG+="uaccess"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="0bb4", ATTRS{idProduct}=="2c87", TAG+="uaccess"
        # HTC Camera USB Node
        SUBSYSTEM=="usb", ATTRS{idVendor}=="114d", ATTRS{idProduct}=="8328", TAG+="uaccess"
        # HTC Mass Storage Node
        SUBSYSTEM=="usb", ATTRS{idVendor}=="114d", ATTRS{idProduct}=="8200", TAG+="uaccess"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="114d", ATTRS{idProduct}=="8a12", TAG+="uaccess"

        # Steam Controller
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="28de", ATTRS{idProduct}=="1142", TAG+="uaccess"
      '';
    })
  ];
}
