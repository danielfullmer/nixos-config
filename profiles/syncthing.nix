{ config, pkgs, lib, ... }:
{
  services.syncthing = {
    enable = true;
    user = "danielrf";
    dataDir = "/home/danielrf/.syncthing/";
    useInotify = true;
  };
  networking.firewall.allowedTCPPorts = [ 22000 ];
}
