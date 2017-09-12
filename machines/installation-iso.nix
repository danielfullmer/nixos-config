# nix-build "<nixpkgs/nixos> -I nixos-config=... -A config.system.build.isoImage
{ config, lib, pkgs, ... }:
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-base.nix>
    ../profiles/base.nix
    ../profiles/yubikey.nix
    ../profiles/desktop
  ];

  boot.kernelPackages = pkgs.linuxPackages_testing_bcachefs;
  boot.extraModulePackages = [ config.boot.kernelPackages.rtl8812au ];
  hardware.enableRedistributableFirmware = true;

  security.sudo.enable = lib.mkForce true;
  security.sudo.wheelNeedsPassword = false;

  networking.wireless.enable = lib.mkForce false;
  networking.networkmanager.enable = true;

  environment.systemPackages = with pkgs; [ 
    gparted
    bcachefs-tools
  ];
}
