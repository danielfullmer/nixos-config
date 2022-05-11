# SPDX-FileCopyrightText: 2020 Daniel Fullmer and robotnix contributors
# SPDX-License-Identifier: MIT

{ overlays ? [ ], ... }@args:

let
  lock = builtins.fromJSON (builtins.readFile ../flake.lock);

  flake-compat = fetchTarball {
    url = "https://github.com/edolstra/flake-compat/archive/${lock.nodes.flake-compat.locked.rev}.tar.gz";
    sha256 = lock.nodes.flake-compat.locked.narHash;
  };

  nixpkgs = (import flake-compat { src = ../.; }).defaultNix.inputs.nixpkgs;

in
import nixpkgs ({
  overlays = overlays ++ (import ./overlays.nix);
} // builtins.removeAttrs args [ "overlays" ])
