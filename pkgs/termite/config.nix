{ pkgs, theme }:

with theme; ''
[options]
font = ${termFontName} ${toString fontSize}

'' + (import (../../modules/theme/templates + "/termite.${brightness}.nix") { inherit colors; })
