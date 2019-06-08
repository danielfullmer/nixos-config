let
  pkgs = import <nixpkgs> {};
in
{
  upload-secrets = pkgs.symlinkJoin {
    name = "upload-secrets";
    paths = (map (machine: (pkgs.nixos (import (./machines + "/${machine}.nix"))).upload-secrets)
             [ "bellman" "nyquist" "euler" "banach" ]);
  };
}
