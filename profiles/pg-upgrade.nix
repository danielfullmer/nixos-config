{ pkgs, config, lib, ... }:

# Module from https://nixos.org/manual/nixos/stable/index.html#module-services-postgres-upgrading
{
  containers.temp-pg.config.services.postgresql = {
    enable = true;
    package = pkgs.postgresql_13;
    ## set a custom new dataDir
    # dataDir = "/some/data/dir";
  };
  environment.systemPackages =
    let newpg = config.containers.temp-pg.config.services.postgresql;
    in [
      (pkgs.writeScriptBin "upgrade-pg-cluster" ''
        set -x
        export OLDDATA="${config.services.postgresql.dataDir}"
        export NEWDATA="${newpg.dataDir}"
        export OLDBIN="${config.services.postgresql.package}/bin"
        export NEWBIN="${newpg.package}/bin"

        install -d -m 0700 -o postgres -g postgres "$NEWDATA"
        cd "$NEWDATA"
        sudo -u postgres $NEWBIN/initdb -D "$NEWDATA"

        systemctl stop postgresql    # old one

        sudo -u postgres $NEWBIN/pg_upgrade \
          --old-datadir "$OLDDATA" --new-datadir "$NEWDATA" \
          --old-bindir $OLDBIN --new-bindir $NEWBIN \
          "$@"
      '')
    ];
}
