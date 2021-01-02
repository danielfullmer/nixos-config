{ config, pkgs, lib, ... }:

# gauss is an external machine on a public provider.
# Minimize and private/secret information on this host.
# Forward any sensitive service to another host over zerotier
with lib;
with (import ../../profiles/nginxCommon.nix);
{
  imports = [
    ../../profiles/base.nix
    ../../profiles/wireguard.nix
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
    interfaces = [ "127.0.0.1" "::1" "10.200.0.1" ];
    allowedAccess = [ "127.0.0.0/24" "10.200.0.0/24" ];
    extraConfig = ''
      local-zone: "daniel.fullmer.me." static
      local-data: "turn.daniel.fullmer.me. IN A 167.71.187.97"
    '' +
      concatStringsSep "\n" (flatten
        (mapAttrsToList (machine: virtualHosts:
          (map (vhost: "local-data: \"${vhost}. IN A ${config.machines.wireguardIP.${machine} or config.machines.zerotierIP.${machine}}\"") virtualHosts))
        config.machines.virtualHosts));
  };

  services.searx.enable = true; # Default port 8888. http://searx.daniel.fullmer.me
  services.searx.configFile = ./searx-settings.yml;

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts = {
      "searx.daniel.fullmer.me" = {
        locations."/".proxyPass = "http://127.0.0.1:8888/";
        # TODO: Use vhostPrivate here, modified to exclude listen on 443?
        listen = [
          { addr = "0.0.0.0"; port = 80; }
          { addr = "0.0.0.0"; port = 9443; ssl = true; extraParameters = [ "proxy_protocol" ]; }
        ];
        forceSSL = true;
        enableACME = true;
        extraConfig = denyInternet + ''
          set_real_ip_from ${config.machines.zerotierIP.gauss}/32;
          real_ip_header proxy_protocol;
        '';
      };
    } //
    (listToAttrs (flatten
      (mapAttrsToList (machine: virtualHosts: (map (vhost:
        nameValuePair vhost { locations."/".proxyPass = "http://${config.machines.zerotierIP.${machine}}/"; })
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
