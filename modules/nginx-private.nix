{ config, pkgs, lib, ... }:

# Adds options to make nginx vhosts public or private to wireguard/zerotier.

with lib;
let
  _config = config;

  denyInternet = ''
    # Allow localhost, zerotier, and wireguard hosts
    allow 127.0.0.1;
    allow ::1;
    allow 30.0.0.0/24;
    allow 10.200.0.0/24;
    deny all;
  '';

  vhostSubmodule = types.submodule ({ config, ... }: {
    options = {
      autoControlNet = mkOption {
        default = true;
        type = types.bool;
      };

      public = mkOption {
        default = false;
        type = types.bool;
      };

      locations = mkOption { type = types.attrsOf locationSubmodule; };
    };

    config = mkIf config.autoControlNet {
      listen = [
        { addr = "0.0.0.0"; port = 80; }
        { addr = "0.0.0.0"; port = 9443; ssl = true; extraParameters = [ "proxy_protocol" ]; }
      ]
        # Gauss vhosts can't listen on 433 since that's reserved for ssl_preread / forwarding by SNI
        ++ optional (_config.networking.hostName != "gauss") { addr = "0.0.0.0"; port = 443; ssl = true; };
      forceSSL = true;
      enableACME = true;
      extraConfig = ''
        # Only allow gauss's zerotier to set a real IP
        set_real_ip_from ${_config.machines.zerotierIP.gauss}/32;
        real_ip_header proxy_protocol;
      '' + optionalString (!config.public) denyInternet;
    };
  });

  locationSubmodule = types.submodule ({ config, ... }: {
    options = {
      public = mkOption {
        default = null; # Using null inherits setting from vhost
        type = types.nullOr types.bool;
      };
    };

    config = {
      extraConfig = mkIf (config.public != null) (
        if config.public
        then "allow all;"
        else denyInternet
      );
    };
  });
in
{
  options = {
    services.nginx.virtualHosts = mkOption { type = types.attrsOf vhostSubmodule; };
  };
}
