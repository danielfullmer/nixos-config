{ config, pkgs, lib, ... }:

# gauss is an external machine on a public provider.
# Minimize and private/secret information on this host.
# Forward any sensitive service to another host over zerotier
with lib;
{
  imports = [
    ../../profiles/personal.nix
    ../../profiles/dns.nix
    ../../profiles/wireguard.nix
    ../../profiles/zerotier.nix
    ../../profiles/tor.nix
  ];

  networking.hostName = "gauss";
  networking.hostId = "394ac2e1";
  networking.nameservers = [ "8.8.8.8" ];

  services.openssh.passwordAuthentication = false;

  documentation.enable = false;

  networking.nat = {
    enable = true;
#    forwardPorts = [
#      { sourcePort = 80; destination = "${config.machines.zerotierIP.bellman}:80"; proto = "tcp"; }
#      { sourcePort = 443; destination = "${config.machines.zerotierIP.bellman}:443"; proto = "tcp"; }
#    ];
    externalInterface = "ens3";
    internalInterfaces = [ "ztmjfpigyc" "wg0" ];
  };
  services.openssh.openFirewall = false;

  nix.gc = {
    automatic = true;
    options = "-d";
  };

  # This is intended just for wireguard clients
  # See also: includes forwarding config from profiles/base.nix
  services.unbound = {
    enable = true;
    settings = {
      server = {
        interface = [ "10.200.0.1" ];
        access-control = [ "10.200.0.0/24 allow" ];

        local-zone = "\"daniel.fullmer.me.\" static";
        local-data = [
          "\"turn.daniel.fullmer.me. IN A 167.71.187.97\""
        ] ++
          (flatten (mapAttrsToList (machine: virtualHosts:
            (map (vhost: "\"${vhost}. IN A ${config.machines.wireguardIP.${machine} or config.machines.zerotierIP.${machine}}\"") virtualHosts))
            config.machines.virtualHosts));
      };
    };
  };

  services.searx.enable = true; # Default port 8888. http://searx.daniel.fullmer.me
  services.searx.environmentFile = config.sops.secrets.searx-env.path;
  services.searx.settings = {
    search.autocomplete = "google";
    search.language = "en-US";
    server.base_url = "https://searx.daniel.fullmer.me/";
    server.image_proxy = true;
    server.secret_key = "@SEARX_SECRET_KEY@";

    # Tor proxies
    outgoing.proxies = {
      http = "http://127.0.0.1:8118";
      https = "http://127.0.0.1:8118";
    };
  };
  sops.secrets.searx-env = {};

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts = {
      "searx.daniel.fullmer.me".locations."/".proxyPass = "http://127.0.0.1:8888/";
    } //
    (listToAttrs (flatten
      (mapAttrsToList (machine: virtualHosts: (map (vhost:
        nameValuePair vhost {
          locations."/".proxyPass = "http://${config.machines.zerotierIP.${machine}}/";
          autoControlNet = false; # Don't enable stuff like ACME ourselves, that'll be done downstream
        })
      virtualHosts)) (filterAttrs (machine: virtualHosts: machine != config.networking.hostName) config.machines.virtualHosts))));

    # Proxy port 80 stuff
    #virtualHosts."hydra.daniel.fullmer.me".locations."/".proxyPass = "http://${config.machines.zerotierIP.bellman}";

    # Forward SSL based on SNI
    appendConfig = let
      targetMapping = concatStringsSep "\n" (flatten
        (mapAttrsToList (machine: virtualHosts:
          (map (vhost: "${vhost} ${config.machines.zerotierIP.${machine}}:9443;") virtualHosts))
        config.machines.virtualHosts));
    in ''
      stream {
        map $ssl_preread_server_name $targetBackend {
          ${targetMapping}
        }

        server {
          listen 443;
          proxy_pass $targetBackend;
          ssl_preread on;
          proxy_protocol on;
        }
      }
    '';
  };
}
