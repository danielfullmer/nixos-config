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
  '';
}
