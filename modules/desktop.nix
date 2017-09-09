{ config, pkgs, lib, ... }:

with lib;

{
  options = {
    services.xserver = {
      desktopManager.extraSessionCommands = mkOption {
        type = types.lines;
        default = "";
      };

     windowManager.i3.config = mkOption {
        type = types.lines;
        default = "";
      };
    };
  };

  config = {
    services.xserver.windowManager.i3.configFile = mkIf (config.services.xserver.windowManager.i3.config != "") (pkgs.writeTextFile {
      name = "i3config";
      text = config.services.xserver.windowManager.i3.config;
    });
  };
}
