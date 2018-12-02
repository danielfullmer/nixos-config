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
  nyquist = (import nixos { configuration = ./machines/nyquist.nix; }).system;
  euler = (import nixos { configuration = ./machines/euler.nix; }).system;
  #banach = (import nixos { configuration = ./machines/banach.nix; }).system;
  spaceheater = (import nixos { configuration = ./machines/spaceheater.nix; }).system;

  tests.desktop = lib.hydraJob (import ./tests/desktop.nix {});
  tests.gpg-agent = lib.hydraJob (import ./tests/gpg-agent.nix {});
  tests.gpg-agent-x11 = lib.hydraJob (import ./tests/gpg-agent-x11.nix {});
  tests.latex-pdf = lib.hydraJob (import ./tests/latex-pdf.nix {});

  tested = pkgs.releaseTools.aggregate {
    name = "tested";
    constituents = [
      bellman bellman-vfio nyquist euler spaceheater
      tests.desktop tests.gpg-agent tests.gpg-agent-x11 tests.latex-pdf
    ];
  };

  nixpkgs-tested = (pkgs.releaseTools.channel {
    name = "nixpkgs-tested-channel";
    src = <nixpkgs>;
    constituents = [ tested ];
  }).overrideAttrs (attrs: {
    # Hack until releaseTools.channel may be unified with nixos/lib/make-channel.nix someday
    patchPhase = attrs.patchPhase + ''
      echo -n pre${toString nixpkgs.revCount}.${nixpkgs.shortRev} > .version-suffix
      echo -n ${nixpkgs.rev or nixpkgs.shortRev} > .git-revision
    '';
  });
  config-tested = pkgs.releaseTools.channel {
    name = "config-tested-channel";
    src = lib.cleanSource ./.;
    constituents = [ tested ];
  };
}
