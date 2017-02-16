{ config, pkgs, lib, ... }:

with lib;

{
  options = {
    services.xserver.desktopManager.extraSessionCommands = mkOption {
      type = types.lines;
      default = "";
    };
  };
}
