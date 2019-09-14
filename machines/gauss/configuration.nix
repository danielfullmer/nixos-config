{ config, pkgs, lib, ... }:

# gauss is an external machine on a public provider.
# Minimize and private/secret information on this host.
# Forward any sensitive service to another host over zerotier
let
  machines = import ../default.nix;
in
{
  imports = [
    ../../profiles/base.nix
    ../../profiles/wireguard.nix
  ];

  networking.hostName = "gauss";
  networking.hostId = "394ac2e1";
  networking.nameservers = [ "8.8.8.8" ];

  #networking.firewall.allowedTCPPorts = [ 80 443 ];
  networking.nat = {
    enable = true;
    forwardPorts = [
      { sourcePort = 80; destination = "${machines.zerotierIP.bellman}:80"; proto = "tcp"; }
      { sourcePort = 443; destination = "${machines.zerotierIP.bellman}:443"; proto = "tcp"; }
    ];
    externalInterface = "ens3";
    internalInterfaces = [ "ztmjfpigyc" "wg0" ];
  };

  nix.gc = {
    automatic = true;
    options = "-d";
  };

  # TODO: Forward to something that resolves over DNS over HTTPS for privacy
  # This is intended just for wireguard clients
  services.unbound = {
    enable = true;
    interfaces = [ "127.0.0.1" "::1" "10.200.0.1" ];
    allowedAccess = [ "127.0.0.0/24" "10.200.0.0/24" ];
    forwardAddresses = [ "8.8.8.8" "8.8.4.4" ];
    extraConfig = ''
      local-zone: "daniel.fullmer.me." static
      local-data: "attestation.daniel.fullmer.me.  IN A 10.200.0.2"
      local-data: "hydra.daniel.fullmer.me.        IN A 10.200.0.2"
      local-data: "playmaker.daniel.fullmer.me.    IN A 10.200.0.2"
      local-data: "fdroid.daniel.fullmer.me.       IN A 10.200.0.2"
      local-data: "office.daniel.fullmer.me.       IN A 10.200.0.2"
      local-data: "daniel.fullmer.me.              IN A 10.200.0.2"
      local-data: "nextcloud.fullmer.me.           IN A 10.200.0.2"
    '';
  };
  networking.networkmanager.dns = lib.mkForce "default";
}
