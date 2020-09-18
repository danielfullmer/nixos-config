{ config, pkgs, ... }:

{
  services.octoprint = {
    enable = true;

  };
  services.udev.extraRules = ''
    SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", SYMLINK+="CrealityEnder3"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", GROUP="octoprint"
  '';
}
