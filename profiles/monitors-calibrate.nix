{ config, pkgs, ... }:

{
  # An alternative is to use colord + xiccd. But this is more declarative.
  # The downside is that it doesn't respond well to plugging in / removing mointors
  environment.etc."xdg/color.jcnf".text = builtins.toJSON (import ../hardware/monitors/color.jcnf.nix);

  # Load display calibration profiles. This needs to happen before redshift gets loaded.
  systemd.user.services.argyllcms = {
    serviceConfig.ExecStart = "${pkgs.argyllcms}/bin/dispwin -L";
    serviceConfig.Type = "oneshot";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    before = [ "redshift.service" ];
  };
}
