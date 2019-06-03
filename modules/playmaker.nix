{ config, pkgs, lib, ... }:

# TODO: Upstream to nixpkgs

with lib;

let
  cfg = config.services.playmaker;
in
{
  options.services.playmaker = {
    enable = mkEnableOption "Fdroid repository manager fetching apps from Play Store";

    device = mkOption {
      type = types.str;
      default = "bacon";
      description = ''
        Specify a device to be used by playmaker.

        For a list of supported devices see <link xlink:href="https://raw.githubusercontent.com/NoMore201/googleplay-api/master/gpapi/device.properties">this file</link>.
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.services.playmaker = {
      description = "Fdroid repository manager fetching apps from Play Store";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      path = with pkgs; [ fdroidserver jdk androidsdk_9_0 ];
      environment = {
        HOME = "%S/playmaker";
        LANG_TIMEZONE = config.time.timeZone;
        DEVICE_CODE = cfg.device;
      };

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
