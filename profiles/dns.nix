{ config, lib, pkgs, ... }: {
  networking.nameservers = [ "127.0.0.1" ];
  services.unbound = {
    enable = true;
    interfaces = [ "127.0.0.1" "::1" ];
    package = pkgs.unbound-with-systemd;

    # services.unbound.forwardAddresses doesn't let us set forward-tls-upstream
    extraConfig = ''
      forward-zone:
        name: "."
        forward-tls-upstream: yes
        # Cloudflare DNS
        forward-addr: 2606:4700:4700::1111@853#cloudflare-dns.com
        forward-addr: 1.1.1.1@853#cloudflare-dns.com
        forward-addr: 2606:4700:4700::1001@853#cloudflare-dns.com
        forward-addr: 1.0.0.1@853#cloudflare-dns.com
        # Quad9
        forward-addr: 2620:fe::fe@853#dns.quad9.net
        forward-addr: 9.9.9.9@853#dns.quad9.net
        forward-addr: 2620:fe::9@853#dns.quad9.net
        forward-addr: 149.112.112.112@853#dns.quad9.net
        # TOR
        #forward-addr: 127.0.0.1@853#cloudflare-dns.com

      server:
        tls-cert-bundle: /etc/pki/tls/certs/ca-bundle.crt
        do-not-query-localhost: no
        edns-tcp-keepalive: yes
    '';
  };

  # Hook up dnsmasq (if used) to unbound
  services.dnsmasq = {
    servers = [ "127.0.0.1" ];
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
