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

  # See https://github.com/NixOS/nixpkgs/issues/17356
  channel =
     { name, src, constituents ? [], meta ? {}, isNixOS ? true, ... }@args:
     pkgs.stdenv.mkDerivation ({
       preferLocalBuild = true;
       _hydraAggregate = true;

       phases = [ "unpackPhase" "patchPhase" "installPhase" ];

       patchPhase = pkgs.stdenv.lib.optionalString isNixOS ''
         touch .update-on-nixos-rebuild
       '';

       installPhase = ''
         mkdir -p $out/{tarballs,nix-support}

         tar cJf "$out/tarballs/nixexprs.tar.xz" \
           --owner=0 --group=0 --mtime="1970-01-01 00:00:00 UTC" \
           --transform='s!^\.!${name}!' .

         echo "channel - $out/tarballs/nixexprs.tar.xz" > "$out/nix-support/hydra-build-products"
         echo $constituents > "$out/nix-support/hydra-aggregate-constituents"

         # Propagate build failures.
         for i in $constituents; do
           if [ -e "$i/nix-support/failed" ]; then
             touch "$out/nix-support/failed"
           fi
         done
       '';

       meta = meta // {
         isHydraChannel = true;
       };
     } // removeAttrs args [ "meta" ]);
in
rec {
  bellman = (import nixos { configuration = ./machines/bellman.nix; }).system;
  bellman-vfio = (import nixos { configuration = ./machines/bellman-vfio.nix; }).system;
  #bellman-steamvr = (import nixos { configuration = ./machines/bellman-steamvr.nix; }).system;
  nyquist = (import nixos { configuration = ./machines/nyquist.nix; }).system;
  euler = (import nixos { configuration = ./machines/euler.nix; }).system;

  nixpkgs-tested = channel {
    name = "nixpkgs-tested";
    src = <nixpkgs>;
    constituents = [ bellman bellman-vfio nyquist euler tests.desktop ];
  };

  tests.desktop = lib.hydraJob (import ./tests/desktop.nix {});
}
