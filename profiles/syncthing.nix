{ config, pkgs, lib, ... }:
with lib;
let
  machines = import ../machines;
in
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
        addresses = [ "tcp://${machines.zerotierIP.${machine}}:22000" ];
      }) (filterAttrs (machine: id: machine != config.networking.hostName) machines.syncthingID); # Filter ourself out

      folders.Sync = {
        path = "/home/danielrf/Sync";
        devices = attrNames config.services.syncthing.declarative.devices;
      };
    };
  };
  # networking.firewall.allowedTCPPorts = [ 22000 ]; # Don't open port. Just work over zerotier
}
