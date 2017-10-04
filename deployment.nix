{
  bellman =
    { config, pkgs, ... }:
    { imports = [ machines/bellman.nix ]; };
  nyquist =
    { config, pkgs, ... }:
    { imports = [ machines/nyquist.nix ]; };
  euler =
    { config, pkgs, ... }:
    { imports = [ machines/euler.nix ]; };
  spaceheater =
    { config, pkgs, ... }:
    { imports = [ machines/spaceheater.nix ]; };
}
