{ config, pkgs, lib, ... }:
{
  services.udev.extraRules = ''
     KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0664", GROUP="wheel", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0113|0114|0115|0116|0120"
  '';

  # Smartcard
  services.pcscd.enable = true;

  environment.systemPackages = (with pkgs; [
    yubico-piv-tool
    yubikey-personalization
  ]);
}
