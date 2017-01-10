{ pkgs, theme }:
pkgs.writeScript "shellTheme" (import (./. + "/theme.${theme.brightness}.nix") { colors=theme.colors; })
