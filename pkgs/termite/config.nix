{ pkgs, theme }:

with theme; ''
[options]
font = ${fontName} ${toString fontSize}

'' + (import (./. + "/theme.${brightness}.nix") { inherit colors; })
