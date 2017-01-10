{ config, pkgs, lib, ... }:

with lib;

let
  defaultTheme = (import ./defaultTheme.nix);
in
{
  options.theme = {
    base16Name = mkOption {
      type = types.str;
      default = defaultTheme.base16Name;
    };

    colors = mkOption {
      type = types.attrsOf types.str;
      default = import (./colors + "/base16-${config.theme.base16Name}.nix");
    };

    brightness = mkOption {
      type = types.str;
      default = defaultTheme.brightness;
    };

    fontName = mkOption {
      type = types.str;
      default = defaultTheme.fontName;
    };

    termFontName = mkOption {
      type = types.str;
      default = defaultTheme.termFontName;
    };

    fontSize = mkOption {
      type = types.int;
      default = defaultTheme.fontSize;
    };

    titleFontSize = mkOption {
      type = types.int;
      default = config.theme.fontSize + 4; # This allows changing only fontSize if desired.
    };

    gtkTheme = mkOption {
      type = types.str;
      default = defaultTheme.gtkTheme;
    };

    gtkIconTheme = mkOption {
      type = types.str;
      default = defaultTheme.gtkIconTheme;
    };
  };
}
