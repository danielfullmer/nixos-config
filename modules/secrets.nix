# Stupid simple secrets uploading to remote hosts

{ config, pkgs, lib, ... }:
with lib;
let
  rsyncFiles = pkgs.writeText "secret-files" (concatStringsSep "\n" (attrNames config.secrets));
  permissionsScript = pkgs.writeText "secret-files-permissions" (''
    sudo -s

  '' + (concatStringsSep "\n" (mapAttrsToList (name: module: ''
    chown ${module.user}:${module.group} "/var/secrets/${module.name}"
    chmod ${module.permissions} "/var/secrets/${module.name}"
    '') config.secrets)));
in
{
  options.secrets = mkOption {
    default = {};
    type = types.loaOf (types.submodule ({ config, ...}: {
      options = {
        name = mkOption {
          default = config._module.args.name;
          type = types.str;
        };

        user = mkOption {
          default = "root";
          type = types.str;
        };

        group = mkOption {
          default = "root";
          type = types.str;
        };

        permissions = mkOption {
          default = "0400";
          type = types.str;
        };
      };
    }));
  };

  config.system.build.upload-secrets = pkgs.writeShellScriptBin "upload-secrets-${config.networking.hostName}" ''
    SECRETSPATH=$1
    if [[ -z "$SECRETSPATH" ]]; then
      SECRETSPATH=/home/danielrf/nixos-config/secrets
    fi

    DEST=$2
    if [[ -z "$DEST" ]]; then
      DEST=${config.networking.hostName}
    fi

    ssh $DEST sudo mkdir -p -m 711 /var/secrets
    rsync --rsync-path="sudo rsync" --files-from=${rsyncFiles} "$SECRETSPATH" "$DEST:/var/secrets"
    ssh $DEST < ${permissionsScript}
  '';
  # TODO: Would be nice to have this all take place over one connection/session
}
