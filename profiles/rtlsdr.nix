{ config, lib, pkgs, ... }:

with lib;
{
  hardware.rtl-sdr.enable = true;
  boot.blacklistedKernelModules = [ "dvb_usb_rtl28xxu" ];

  # GUI stuff
  environment.systemPackages = with pkgs; [ rtl-sdr gqrx rtl_433
    #dump1090
  ];
}
