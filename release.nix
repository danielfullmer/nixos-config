let
  pkgs' = import <nixpkgs> {};
in
{ nixpkgs ? pkgs'.fetchFromGitHub {
    owner = "nixos";
    repo = "nixpkgs";
    rev = "0843ad10fd5cf984b36cf7e6533a518cab299af4";
    sha256 = "1c8jwqszhr0383pbbr11qls2k61akbhwjmj6q2ck4z2c3m6rcsxk";
  }
}:

with pkgs'.lib;

let
  nixos = nixpkgs + /nixos;
in
{
  bellman = (import nixos { configuration = ./machines/bellman.nix; }).system;
  bellman-vfio = (import nixos { configuration = ./machines/bellman-vfio.nix; }).system;
  bellman-steamvr = (import nixos { configuration = ./machines/bellman-steamvr.nix; }).system;
  nyquist = (import nixos { configuration = ./machines/nyquist.nix; }).system;
  euler = (import nixos { configuration = ./machines/euler.nix; }).system;

  tests.desktop = hydraJob (import ./tests/desktop.nix {});
}
