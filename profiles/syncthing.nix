{ config, pkgs, lib, ... }:
{
  services.syncthing = {
    enable = true;
    user = "danielrf";
    dataDir = "/home/danielrf/.syncthing/";
  };
  networking.firewall.allowedTCPPorts = [ 22000 ];
}
