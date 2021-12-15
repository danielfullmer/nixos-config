# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    ../../profiles/base.nix
    ../../profiles/dns.nix
    ../../profiles/interactive.nix
    ../../profiles/extended.nix
    ../../profiles/zerotier.nix
    ../../profiles/yubikey.nix
    ../../profiles/desktop/default.nix
  ];

  system.stateVersion = "22.05";

  networking.hostName = "riemann";
  networking.hostId = "e1feebf3";

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  networking.networkmanager.enable = true;

  programs.light.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest; # For wifi support
  services.fprintd.enable = true; # Fingerprint support

  services.xserver.libinput.enable = true;

  theme.fontSize = 8;
}
