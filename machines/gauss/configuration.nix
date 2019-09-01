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
    internalInterfaces = [ "ztmjfpigyc" ];
  };

  nix.gc = {
    automatic = true;
    options = "-d";
  };
}
