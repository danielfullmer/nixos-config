{ nixpkgs ? { outPath = ./../nixpkgs; revCount = 56789; shortRev = "gfedcba"; }
, stableBranch ? false
, supportedSystems ? [ "x86_64-linux" ]
}:

# See also: https://github.com/openlab-aux/vuizvui
let
  pkgs = import nixpkgs {};
  lib = import (nixpkgs + /lib);
  nixos = nixpkgs + /nixos;

  version = lib.fileContents (nixos + "/../.version");
  versionSuffix =
    (if stableBranch then "." else "pre") + "${toString nixpkgs.revCount}.${nixpkgs.shortRev}";

in
{
  bellman = (import nixos { configuration = ./machines/bellman.nix; }).system;
  bellman-vfio = (import nixos { configuration = ./machines/bellman-vfio.nix; }).system;
  bellman-steamvr = (import nixos { configuration = ./machines/bellman-steamvr.nix; }).system;
  nyquist = (import nixos { configuration = ./machines/nyquist.nix; }).system;
  euler = (import nixos { configuration = ./machines/euler.nix; }).system;

  channel = (import (nixos + "/lib/make-channel.nix") { inherit pkgs nixpkgs version versionSuffix; });

  tests.desktop = lib.hydraJob (import ./tests/desktop.nix {});
}
