rec {
  # Base16 colors
  base16Name = "chalk";
  colors = import (./colors + "/base16-${base16Name}.nix");
  brightness = "dark";

  # Default fonts
  fontName = "Roboto";
  termFontName = "Roboto Mono for Powerline";
  fontSize = 10; # Suggestion: set fontSize = 0.45 * distance to monitor
  titleFontSize = 14; # Example value. See theme.nix

  # GTK
  gtkTheme = "Adapta";
  gtkIconTheme = "Adwaita";
}

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
