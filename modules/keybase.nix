{ config, pkgs, lib, ... }:
with lib;

let
  cfg = config.programs.keybase;
in
{
  options = {
    programs.keybase = {
      enable = mkEnableOption "keybase";

      package = mkOption {
        type = types.path;
        default = pkgs.keybase;
      };

      mountPoint = mkOption {
        type = types.path;
        default = /keybase;
      };
    };
  };

  config = mkIf (config.programs.keybase.enable) {
    # TODO: Try to make this multi-user. Right now this only works for danielrf, and mounts at /keybase
    # I use systemd.user services to get the right environment varibles (HOME/XDG_USER_DIR/etc)
    systemd.user = {
      # TODO: See https://github.com/keybase/client/issues/3508
      # sockets.keybase = {
      #   description = "Keybase socket";
      #   after = [ "network.target" ];
      #   wantedBy = [ "sockets.target" ];
      #   socketConfig.ListenStream = "%t/keybase/keybased.sock";
      # };

      services.keybase = {
        description = "Keybase service";
        after = [ "network.target" ];
        wantedBy = [ "default.target" ]; # TODO: Remove this when socket-activation works
        serviceConfig = {
          ExecStart = "${cfg.package}/bin/keybase service";
        };
      };

      # TODO: Change this to a systemd.mount. See the github issue above
      services.kbfs = {
        description = "Keybase filesystem";
        after = [ "keybase.service" ];
        wantedBy = [ "default.target" ];
        serviceConfig = {
          Environment = "PATH=/run/wrappers/bin"; # XXX: Needed for fusermount
          ExecStart = "${pkgs.kbfs}/bin/kbfsfuse /keybase";
        };
      };
    };

    # TODO: Remove this hack when keybase becomes multi-user
    system.activationScripts.keybase = lib.stringAfter [ "users" "groups" ] ''
      # XXX: Can't just do [[ ! -d /keybase ]] since root can't even stat() this dir if mounted
      if ls -f / | grep -q keybase; then false;
      else
        mkdir /keybase
        chown danielrf:danielrf /keybase
      fi
    '';

    services.xserver.desktopManager.extraSessionCommands = "(${pkgs.keybase-gui}/bin/keybase-gui) &";

    environment.systemPackages = [ pkgs.keybase-gui ];
  };
}
