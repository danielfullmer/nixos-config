# nix-build "<nixpkgs/nixos> -I nixos-config=... -A config.system.build.isoImage
{ config, lib, pkgs, ... }:
{
  imports = [
    <nixpkgs/nixos/modules/profiles/base.nix>
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-base.nix>
    ../profiles/base.nix
    ../profiles/interactive.nix
    ../profiles/yubikey.nix
    ../profiles/desktop
  ];

  boot.extraModulePackages = [ config.boot.kernelPackages.rtl8812au ];
  hardware.enableRedistributableFirmware = true;

  boot.supportedFilesystems = [ "zfs" ];
  boot.initrd.supportedFilesystems = [ "zfs" ];

  security.sudo.enable = lib.mkForce true;
  security.sudo.wheelNeedsPassword = false;

  networking.wireless.enable = lib.mkForce false;
  networking.networkmanager.enable = true;

  environment.systemPackages = with pkgs; [
    gparted
    bcachefs-tools
    parted
    ntfs3g
  ] ++ lib.optional (!(config.system.build ? vm)) (import <nixpkgs/nixos> {}).vm;
  # Make a VM of ourself, in case we'd like to spin a VM with -snapshot to not modify the disk
  # Only make one if we are not already a VM ourself (to avoid infinite loops)
}
