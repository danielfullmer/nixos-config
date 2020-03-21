{ config, pkgs, lib, ... }:
with lib;
{
  services.syncthing = {
    enable = true;
    user = "danielrf";
    dataDir = "/home/danielrf/.syncthing/";
    declarative = {
      overrideDevices = true;
      # TODO: Track certs and private keys in secrets?
      devices = mapAttrs (machine: id: {
        inherit id;
        addresses = [ "tcp://${config.machines.zerotierIP.${machine}}:22000" ];
      }) (filterAttrs (machine: id: machine != config.networking.hostName) config.machines.syncthingID); # Filter ourself out

      folders.Sync = {
        path = "/home/danielrf/Sync";
        devices = attrNames config.services.syncthing.declarative.devices;
      };
    };
  };
  # networking.firewall.allowedTCPPorts = [ 22000 ]; # Don't open port. Just work over zerotier
  #services.nginx.virtualHosts.localhost.locations."/syncthing/".proxyPass = "http://127.0.0.1:8384/";
}
