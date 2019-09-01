{ config, lib, pkgs, ... }:

let
  extlinux-conf-builder =
    import <nixpkgs/nixos/modules/system/boot/loader/generic-extlinux-compatible/extlinux-conf-builder.nix> {
      inherit pkgs;
    };
in
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/sd-image-aarch64.nix>
  ];

  system.stateVersion = "19.03";

  boot.initrd.availableKernelModules = [ "usbhid" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ config.boot.kernelPackages.rtl8812au ];

  hardware.firmware = with pkgs; [ raspberrypiWirelessFirmware ];

  nix.maxJobs = 2;
  nix.buildCores = 4;
}
