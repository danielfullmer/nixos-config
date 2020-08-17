let
  pkgs = import <nixpkgs> {};
in
{
  upload-secrets = pkgs.symlinkJoin {
    name = "upload-secrets";
    paths = (map (machine: (pkgs.nixos (import (./machines + "/${machine}"))).upload-secrets)
             [ "bellman" "euler" "banach" "gauss" ]);
  };
}
