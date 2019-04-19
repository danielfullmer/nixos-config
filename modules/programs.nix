{ config, pkgs, lib, ... }:

with lib;

# Various config files
{
  options = {
    hardware.dactyl.keymap = mkOption {
      type = types.lines;
      default = "";
    };

    programs = {
      dunst.config = mkOption {
        type = types.attrsOf types.attrs;
        default = {};
      };

      termite.config = mkOption {
        type = types.lines;
        default = "";
      };

      tmux.config = mkOption {
        type = types.lines;
        default = "";
      };

      vim = {
        knownPlugins = mkOption {
          type = types.attrs;
          default = {};
        };

        pluginDictionaries = mkOption {
          type = types.listOf types.attrs;
          default = [];
        };

        config = mkOption {
          type = types.lines;
          default = "";
        };
      };

      zathura.config = mkOption {
        type = types.lines;
        default = "";
      };
    };

    services.xserver = {
      xresources = mkOption {
        type = types.lines;
        default = "";
      };

      desktopManager.extraSessionCommands = mkOption {
        type = types.lines;
        default = "";
      };

     windowManager.i3.config = mkOption {
        type = types.lines;
        default = "";
      };

     windowManager.i3.barsDefaultConfig = mkOption {
        type = types.lines;
        default = "";
      };

     windowManager.i3.bars = mkOption {
        type = types.listOf types.lines;
        default = [];
      };
    };
  };

  config = {
    services.xserver.windowManager.i3.configFile = mkIf (config.services.xserver.windowManager.i3.config != "") (pkgs.writeTextFile {
      name = "i3config";
      text = config.services.xserver.windowManager.i3.config + (concatMapStrings (barconfig: ''
        bar {
          ${barconfig}
          ${config.services.xserver.windowManager.i3.barsDefaultConfig}
        }
      '') config.services.xserver.windowManager.i3.bars);
    });
  };
}
