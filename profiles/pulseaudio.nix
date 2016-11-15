{ config, pkgs, lib, ... }:
{
  hardware.pulseaudio = {
    enable = true;
    tcp.enable = true;
    tcp.anonymousClients.allowedIpRanges = [ "30.0.0.0/24" ];
    zeroconf.discovery.enable = true;
    zeroconf.publish.enable = true;
  };

  security.rtkit.enable = true;
}
