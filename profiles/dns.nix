{ config, lib, pkgs, ... }: {
  networking.nameservers = [ "127.0.0.1" ];
  services.unbound = {
    enable = true;
    package = pkgs.unbound-with-systemd;

    # services.unbound.forwardAddresses doesn't let us set forward-tls-upstream
    settings = {
      forward-zone = [ {
        name = ".";
        forward-tls-upstream = true;
        forward-addr = [
          # Cloudflare DNS
          "2606:4700:4700::1111@853#cloudflare-dns.com"
          "1.1.1.1@853#cloudflare-dns.com"
          "2606:4700:4700::1001@853#cloudflare-dns.com"
          "1.0.0.1@853#cloudflare-dns.com"
          # Quad9
          "2620:fe::fe@853#dns.quad9.net"
          "9.9.9.9@853#dns.quad9.net"
          "2620:fe::9@853#dns.quad9.net"
          "149.112.112.112@853#dns.quad9.net"
          # TOR
          #"127.0.0.1@853#cloudflare-dns.com"
        ];
      } ];

      server = {
        interface = [ "127.0.0.1" "::1" ];
        access-control = [ "127.0.0.0/8 allow" "::1/128 allow" ];
        do-not-query-localhost = false;
        edns-tcp-keepalive = true;
      };
    };
  };

  # Hook up dnsmasq (if used) to unbound
  services.dnsmasq = {
    settings.server = [ "127.0.0.1" ];
    resolveLocalQueries = false;
    extraConfig = ''
      except-interface=lo
      bind-interfaces
      no-hosts
    '';
  };

  # Provides cloudflare DNS over TOR
  systemd.services.tor-dns = lib.mkIf config.services.tor.enable {
    script = ''
      ${pkgs.socat}/bin/socat TCP4-LISTEN:853,bind=127.0.0.1,reuseaddr,fork SOCKS4A:127.0.0.1:dns4torpnlfs2ifuz2s2yf3fc7rdmsbhm6rw75euj35pac6ap25zgqad.onion:853,socksport=9063
    '';
    wantedBy = [ "unbound.service" ];
  };
}
