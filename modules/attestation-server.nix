{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.attestation-server;
in
{
  options.services.attestation-server = {
    enable = mkEnableOption "Hardware-based remote attestation service for monitoring the security of Android devices using the Auditor app";

    listenHost = mkOption {
      default = "localhost";
      type = types.str;
    };

    port = mkOption {
      default = 5000;
      type = types.int;
    };

    domain = mkOption {
      default = "attestation.app";
      type = types.str;
    };

    platformFingerprint = mkOption {
      default = "";
      type = types.str;
    };

    deviceFamily = mkOption {
      default = "";
      type = types.str;
    };

    avbFingerprint = mkOption {
      default = "";
      type = types.str;
    };

    package = mkOption {
      default = pkgs.attestation-server.override {
        inherit (cfg) listenHost port domain platformFingerprint deviceFamily avbFingerprint;
      };
      type = types.path;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.attestation-server = {
      description = "Attestation Server";
      wantedBy = [ "multi-user.target" ];
      requires = [ "network-online.target" ];

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/AttestationServer";

        DynamicUser = true;
        ProtectSystem = "strict";
        ProtectHome = true;

        NoNewPrivileges = true;
        StateDirectory = "attestation";
        WorkingDirectory = "%S/attestation";
      };
    };
  };
}
