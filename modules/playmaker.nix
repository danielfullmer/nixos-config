{ config, pkgs, lib, ... }:

# TODO: Upstream to nixpkgs

with lib;

let
  cfg = config.services.playmaker;
in
{
  options.services.playmaker = {
    enable = mkEnableOption "Fdroid repository manager fetching apps from Play Store";
  };

  config = mkIf cfg.enable {
    systemd.services.playmaker = {
      description = "Fdroid repository manager fetching apps from Play Store";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      path = with pkgs; [ fdroidserver jdk androidsdk_9_0 ];
      environment.HOME = "%S/playmaker";

      serviceConfig = {
        ExecStart = "${pkgs.playmaker}/bin/pm-server -f -d";

        # TODO: optionally set HTTPS_CERTFILE / HTTPS_KEYFILE
        # Patch for port, listen address?
        # CRONTAB_STRING as well. see pm-server source
        # Set credentials externally?

        DynamicUser = true;
        ProtectSystem = "strict";
        ProtectHome = true;

        NoNewPrivileges = true;
        StateDirectory = "playmaker";
        WorkingDirectory = "%S/playmaker";
      };
    };
  };
}
