{ config, pkgs, lib, ... }:

# base00 - Default Background
# base01 - Lighter Background (Used for status bars)
# base02 - Selection Background
# base03 - Comments, Invisibles, Line Highlighting
# base04 - Dark Foreground (Used for status bars)
# base05 - Default Foreground, Caret, Delimiters, Operators
# base06 - Light Foreground (Not often used)
# base07 - Light Background (Not often used)

# Default base16 colors
# base08 - Red
# base09 - Orange
# base0A - Yellow
# base0B - Green
# base0C - Cyan
# base0D - Blue
# base0E - Magenta
# base0F - Brown

let
  template = name: import (./templates + "/${name}.${config.theme.brightness}.nix") { inherit (config.theme) colors; };
in with lib;
{
  options.theme = {
    base16Name = mkOption {
      type = types.str;
      default = "chalk";
    };

    colors = mkOption {
      type = types.attrsOf types.str;
      default = import (./colors + "/base16-${config.theme.base16Name}.nix");
    };

    brightness = mkOption {
      type = types.str;
      default = "dark";
    };

    fontName = mkOption {
      type = types.str;
      default = "Roboto";
    };

    termFontName = mkOption {
      type = types.str;
      default = "Roboto Mono for Powerline";
    };

    fontSize = mkOption {
      type = types.int;
      default = 10; # Suggestion: set fontSize = 0.45 * distance to monitor
    };

    titleFontSize = mkOption {
      type = types.int;
      default = config.theme.fontSize + 4; # This allows changing only fontSize if desired.
    };

    gtkTheme = mkOption {
      type = types.str;
      default = "Orchis";
    };

    gtkIconTheme = mkOption {
      type = types.str;
      default = "Adwaita";
    };

    background = mkOption {
      type = types.path;
      default = ./806427.jpg;
    };
  };

  config = with config.theme; {
    programs.bash.interactiveShellInit = template "shell";
    programs.zsh.interactiveShellInit = template "shell";
    programs.fish.interactiveShellInit = template "shell";

    programs.dunst.config = {
        global = {
          font = "${fontName} ${toString (fontSize+2)}";
          icon_path = "/run/current-system/sw/share/icons/${config.theme.gtkIconTheme}/32x32/status/:/run/current-system/sw/share/icons/${config.theme.gtkIconTheme}/share/icons/gnome/32x32/devices/";
        };
      } // template "dunst";

    programs.termite.config = ''
      [options]
        font = ${termFontName} ${toString fontSize}
      '' + template "termite";

    programs.vim.knownPlugins = {
      # Airline theme can't be directly sourced anymore. Needs to be in under <rtp>/autoload/airline/themes/
      airlineThemeBase16 = pkgs.vimUtils.buildVimPlugin {
        name = "airlineThemeBase16";
        # TODO: Should be able to use writeTextDir, but that's broken too: https://github.com/NixOS/nixpkgs/issues/50347
        src = pkgs.writeTextFile {name="airlineTheme"; destination="/autoload/airline/themes/base16_nixos_configured.vim"; text=template "airline";};
      };
    };

    programs.vim.pluginDictionaries = [
      { names = [
        "airlineThemeBase16" # Custom base16 colors
      ]; }
    ];

    programs.vim.config = let
      shellThemeScript = pkgs.writeScript "shellTheme" (template "shell");
    in ''
        set background=${brightness}
        let base16colorspace=256
        if !has('gui_running')
          execute "silent !/bin/sh ${shellThemeScript}"
        endif
        source ${pkgs.writeText "vimTheme" (template "neovim")}

        " Use the theme from airlineThemeBase16
        let g:airline_theme="base16_nixos_configured"
        let g:airline_powerline_fonts=1
    '';

    programs.zathura.config = template "zathura";

    services.xserver.xresources = template "xresources";

    services.xserver.windowManager.i3.config = ''
      # Font for window titles. Will also be used by the bar unless a different font
      # is used in the bar {} block below.
      font pango:${fontName} ${toString titleFontSize}
    '' + template "i3";

    services.xserver.windowManager.i3.barsDefaultConfig = template "i3bar";
  };
}
