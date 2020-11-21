{ config, lib, pkgs, ... }:

with lib;
{
  hardware.rtl-sdr.enable = true;
  boot.blacklistedKernelModules = [ "dvb_usb_rtl28xxu" ];

  # GUI stuff
  environment.systemPackages = with pkgs; [ gqrx ];
}
