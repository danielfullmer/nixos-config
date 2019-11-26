{ config, pkgs, ... }:

{
  imports = [
    ../../profiles/base.nix
    ../../profiles/interactive.nix
    ../../profiles/extended.nix
    ../../profiles/yubikey.nix
    ../../profiles/desktop/default.nix
    ../../profiles/academic.nix
    ../../profiles/gdrive.nix
    ../../profiles/tor.nix
  ];

  networking.hostName = "nyquist";
  networking.hostId = "d8ab690e";

  services.plex.enable = true;
  networking.firewall.allowedTCPPorts = [ 32400 ];

  environment.systemPackages = with pkgs; [ keyboard-firmware ];

  system.autoUpgrade.enable = true;

  programs.adb.enable = true;
  users.users.danielrf.extraGroups = [ "adbusers" ];
}