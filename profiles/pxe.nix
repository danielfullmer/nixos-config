{ config, pkgs, lib, ... }:
# Try out https://github.com/NixOS/nixpkgs/pull/83443
let
  #interface = "enp69s0";
  interface = "enp68s0";
  subnetNumber = 5;
  networkPrefix = "192.168.${toString subnetNumber}";
in
{
  networking.interfaces.${interface}.ipv4.addresses = [ { address = "${networkPrefix}.1"; prefixLength = 24; } ];
  networking.firewall.trustedInterfaces = [ interface ]; # TODO. Manually set ports to be exported
  networking.nat.internalInterfaces = [ interface ];

  services.nfs.server = {
    enable = true;
    hostName = "192.168.1.200"; # Listen on this address
    exports = ''
      /nix/store 192.168.1.0/16(ro)
    '';
      #/nix/store ${networkPrefix}.0/24(ro)
  };

  services.dnsmasq = {
    enable = true;
    extraConfig = ''
      interface=${interface}

      # First MAC address is for pinecube uboot, native linux has a different
      # MAC and will use normal DHCP
      dhcp-host=02:01:51:db:b2:9d,set:pxe
      dhcp-range=interface:${interface},tag:pxe,${networkPrefix}.2,${networkPrefix}.254
      enable-tftp
      tftp-root=/var/lib/tftpboot
    '';
  };
}
