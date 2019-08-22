{ config, pkgs, lib, ... }:

# gauss is an external machine on a public provider.
# Minimize and private/secret information on this host.
# Forward any sensitive service to another host over zerotier
let
  machines = import ./default.nix;
  externalIP = "167.71.187.97";
in
{
  imports = [
    <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
    ../profiles/base.nix
  ];

  system.stateVersion = "19.03";

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
    #externalIP = externalIP;
  };

  nix.gc = {
    automatic = true;
    options = "-d";
  };

  # Stuff from nixos-infect below:
  boot.loader.grub.device = "/dev/vda";
  fileSystems."/" = { device = "/dev/vda1"; fsType = "ext4"; };

  networking.defaultGateway = "167.71.176.1";
  networking.defaultGateway6 = "";
  networking.dhcpcd.enable = false;
  networking.usePredictableInterfaceNames = lib.mkForce true;
  networking.interfaces = {
    ens3 = {
      ipv4.addresses = [
        { address=externalIP; prefixLength=20; }
        { address="10.17.0.5"; prefixLength=16; }
      ];
      ipv6.addresses = [
        { address="fe80::bc4e:eeff:fe18:60e8"; prefixLength=64; }
      ];
    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="be:4e:ee:18:60:e8", NAME="ens3"
  '';
}
