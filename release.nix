{ nixpkgs ? { outPath = ./../nixpkgs; revCount = 56789; shortRev = "gfedcba"; }
, stableBranch ? false
, supportedSystems ? [ "x86_64-linux" ]
}:

# See also: https://github.com/openlab-aux/vuizvui
let
  pkgs = import nixpkgs {};
  lib = import (nixpkgs + /lib);
  nixos = nixpkgs + /nixos;
in
rec {
  bellman = (import nixos { configuration = ./machines/bellman.nix; }).system;
  bellman-vfio = (import nixos { configuration = ./machines/bellman-vfio.nix; }).system;
  #bellman-steamvr = (import nixos { configuration = ./machines/bellman-steamvr.nix; }).system;
  nyquist = (import nixos { configuration = ./machines/nyquist.nix; }).system;
  euler = (import nixos { configuration = ./machines/euler.nix; }).system;

  tests.desktop = lib.hydraJob (import ./tests/desktop.nix {});
  tests.gpg-agent = lib.hydraJob (import ./tests/gpg-agent.nix {});
  tests.gpg-agent-x11 = lib.hydraJob (import ./tests/gpg-agent-x11.nix {});

  tested = pkgs.releaseTools.aggregate {
    name = "tested";
    constituents = [ bellman bellman-vfio nyquist euler tests.desktop tests.gpg-agent tests.gpg-agent-x11 ];
  };

  nixpkgs-tested = pkgs.releaseTools.channel {
    name = "nixpkgs-tested";
    src = <nixpkgs>;
    constituents = [ tested ];
  };
  config-tested = pkgs.releaseTools.channel {
    name = "config-tested";
    src = ./.;
    constituents = [ tested ];
  };
}
