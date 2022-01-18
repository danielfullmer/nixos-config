{ config, pkgs, lib, ... }:

with lib;
{
  imports = [
    ../../profiles/personal.nix
    ../../profiles/dns.nix
    ../../profiles/interactive.nix
    ../../profiles/extended.nix
    ../../profiles/zerotier.nix
    ../../profiles/yubikey.nix
    #../../profiles/syncthing.nix
    ../../profiles/desktop/default.nix
    #../../profiles/academic.nix
    #../../profiles/gdrive.nix
  ];

  networking.hostName = "laplace";
  networking.hostId = "36e832af";

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  networking.networkmanager.enable = true;

  programs.light.enable = true;

  services.xserver.videoDrivers = [ "modesetting" ];
  services.xserver.libinput = {
    enable = true;
    touchpad.accelSpeed = "0.35";
  };

  theme.fontSize = 12;

  services.redshift.enable = true;

  programs.chromium.extensions = [ "aleakchihdccplidncghkekgioiakgal" ]; # h264ify
}
