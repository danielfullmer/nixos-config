{
  programs.chromium.extensions = [
    "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Darkreader
  ];

  theme.base16Name = "bright";

  services.xserver.windowManager.i3.barsDefaultConfig = ''
    # Auto-hide bars. Press $mod+4 to show temporarily
    mode hide
  '';
}
