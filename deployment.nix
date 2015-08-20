{
  bellman =
    { config, pkgs, ... }:
    { imports = [ machines/bellman.nix ]; };
  nyquist =
    { config, pkgs, ... }:
    { imports = [ machines/nyquist.nix ]; };
}
