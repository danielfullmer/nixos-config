rec {
  # Base16 colors
  name = "irblack";
  colors = (import ./colors/base16-irblack.nix);

  # Default fonts
  fontName = "DejaVu Sans Mono for Powerline";
  fontSize = "12";
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
