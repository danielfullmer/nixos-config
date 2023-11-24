{ config, pkgs, lib, ... }:
# Try out https://github.com/NixOS/nixpkgs/pull/83443
let
  #interface = "enp69s0";
  interface = "netboot"; # On a VLAN
  subnetNumber = 5;
  networkPrefix = "192.168.${toString subnetNumber}";
  ipAddress = "${networkPrefix}.1";
in
{
  networking.interfaces.${interface}.ipv4.addresses = [ { address = ipAddress; prefixLength = 24; } ];
  networking.firewall.trustedInterfaces = [ interface ]; # TODO. Manually set ports to be exported
  networking.nat.internalInterfaces = [ interface ];

  services.nfs.server = {
    enable = true;
    hostName = ipAddress; # Listen on this address
    exports = ''
      /nix/store ${networkPrefix}.0/24(ro)
    '';
  };

  services.dnsmasq = {
    enable = true;
    settings = {
      inherit interface;

      # First MAC address is for pinecube uboot, native linux has a different
      # MAC and will use normal DHCP
      dhcp-range = "interface:${interface},${networkPrefix}.2,${networkPrefix}.254";
      #enable-tftp = true;
      #tftp-root = "/var/lib/tftpboot";
    };
  };
}
