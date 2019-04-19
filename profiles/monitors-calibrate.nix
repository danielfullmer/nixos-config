{ config, pkgs, ... }:

{
  # An alternative is to use colord + xiccd. But this is more declarative.

  environment.etc."xdg/color.jcnf".text = builtins.toJSON (import ../hardware/monitors/color.jcnf.nix);

  # Load display calibration profiles. This needs to happen before redshift gets loaded.
  # Currently this seems to work ok, but I don't believe it's guaranteed to work. There isn't an explicit dependency.
  services.xserver.desktopManager.extraSessionCommands = "${pkgs.argyllcms}/bin/dispwin -L";
}
