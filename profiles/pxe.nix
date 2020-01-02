{ config, pkgs, lib, ... }:
{
  networking.interfaces.enp5s0.ipv4.addresses = [ { address = "10.0.0.1"; prefixLength = 24; } ];
  networking.firewall.trustedInterfaces = [ "enp5s0" ]; # TODO. Manually set ports to be exported
  networking.nat.internalInterfaces = [ "enp5s0" ];

  services.nfs.server = {
    enable = true;
    hostName = "10.0.0.1"; # Listen on this address
    exports = ''
      /nix/store 10.0.0.0/24(ro)
    '';
  };

  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;
    servers = [ "8.8.8.8" "8.8.4.4" ];
    extraConfig = ''
      interface=enp5s0
      bind-dynamic

      #port=0
      dhcp-range=10.0.0.2,10.0.0.254
      enable-tftp
      tftp-root=/var/lib/tftpboot
    '';
  };
}
