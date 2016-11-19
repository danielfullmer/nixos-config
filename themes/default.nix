rec {
  # Base16 colors
  name = "irblack";
  colors = (import "./colors/base16-${name}.nix");

  # Default fonts
  fontName = "DejaVu Sans Mono for Powerline";
  fontSize = "12";
}
