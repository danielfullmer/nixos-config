{ config, pkgs, ... }:
{
  # Default ports are: 9050 (SOCKS w/ IsolateDestAddr), 9063 (SOCKS), 8118 (privoxy, use for browsers)
  services.tor = {
    enable = true;
    client.enable = true;
    client.dns.enable = true;
  };
}
