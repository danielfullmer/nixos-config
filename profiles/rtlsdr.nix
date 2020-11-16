{ config, lib, pkgs, ... }:

with lib;
{
  services.udev.packages = with pkgs; [ rtl-sdr ];
  boot.blacklistedKernelModules = [ "dvb_usb_rtl28xxu" ];

  # GUI stuff
  environment.systemPackages = with pkgs; [ gqrx ];
}
