{ pkgs, theme }:

with theme; ''
[options]
font = ${termFontName} ${toString fontSize}

'' + (import (./. + "/theme.${brightness}.nix") { inherit colors; })
