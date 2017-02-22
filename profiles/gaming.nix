{ config, pkgs, lib, ... }:
{
  hardware.opengl.driSupport32Bit = true; # Needed for steam
  hardware.pulseaudio.support32Bit = true;

  services.xserver.modules = [ pkgs.xlibs.xf86inputjoystick ];

  environment.systemPackages = (with pkgs; [
    (steam.override {newStdcpp = true; }) # Option needed for radeon drivers
  ]);

  services.udev.extraRules = ''
    ### Steam Controller ###
    SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", TAG+="uaccess"
    KERNEL=="uinput", MODE="0660", GROUP="users", OPTIONS+="static_node=uinput"

    ### HTC Vive ###

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
  '';
}
