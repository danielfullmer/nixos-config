{ config, pkgs, lib, ... }:

with (import ./nginxCommon.nix);
{
  services.nginx.enable = true;
  services.nginx.recommendedProxySettings = true;

  services.nginx.virtualHosts."nextcloud.fullmer.me" = {
    locations."/".proxyPass = "http://10.100.0.2/";
    forceSSL = true;
    enableACME = true;
    extraConfig = denyInternet;
  };

  networking.nat.enable = true;
  networking.nat.internalIPs = [ "10.100.0.2" ];
  containers.nextcloud = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "10.100.0.1";
    localAddress = "10.100.0.2";
    config = { config, pkgs, ... }:
    {
      networking.hosts = {
        "10.100.0.1" = [ "office.daniel.fullmer.me" ];
      };
      networking.nameservers = [ "8.8.8.8" ];

      services.nextcloud = {
        enable = true;
        hostName = "nextcloud.fullmer.me";
        autoUpdateApps.enable = true;
        config = {
          dbtype = "sqlite";
          # dbtype = "pgsql"; # TODO: Convert to postgres?
          #dbuser = "nextcloud";
          #dbhost = "/run/postgresql"; # nextcloud will add /.s.PGSQL.5432 by itself
          #dbname = "nextcloud";
          adminpassFile = "/var/secrets/nextcloud";
          adminuser = "root";
          extraTrustedDomains = [ "10.100.0.2" ]; # Ensure the "proxyPass" location is a valid domain
          overwriteProtocol = "https"; # Since we're behind nginx reverse proxy, we need to know that we should always use https
        };
      };

      services.postgresql = {
        #enable = true;
        initialScript = pkgs.writeText "psql-init" ''
          CREATE ROLE nextcloud WITH LOGIN;
          CREATE DATABASE nextcloud WITH OWNER nextcloud;
        '';
      };

      # ensure that postgres is running *before* running the setup
      #systemd.services."nextcloud-setup" = {
      #  requires = ["postgresql.service"];
      #  after = ["postgresql.service"];
      #};

      networking.firewall.allowedTCPPorts = [ 80 443 ];

      environment.systemPackages = with pkgs; [ ffmpeg imagemagick ghostscript ];
    };
  };

#  docker-containers.onlyoffice = {
#    image = "onlyoffice/documentserver";
#    ports = [ "9980:80" ];
#    extraDockerOptions = [ "--add-host=office.daniel.fullmer.me:30.0.0.222" ];
#  };

  # https://www.collaboraoffice.com/code/docker/ for instructions
  docker-containers.code = {
    image = "collabora/code";
    ports = [ "9980:9980" ];
    environment = {
      domain = "nextcloud\\.fullmer\\.me";
    };
    extraDockerOptions = [
      "--cap-add=MKNOD"
      "--add-host=office.daniel.fullmer.me:30.0.0.222"
    ];
  };
  services.nginx.virtualHosts."office.daniel.fullmer.me" = {
    locations."/" = {
      proxyPass = "https://[::1]:9980";
      # proxyPass = "http://[::1]:9980/"; # For onlyoffice
      proxyWebsockets = true;
#      extraConfig = ''
#        proxy_set_header Host $http_host;
#        proxy_read_timeout 3600
#      '';
    };
    forceSSL = true;
    enableACME = true;
    extraConfig = denyInternet;
  };
}
