{ config, lib, pkgs, ... }:

# nix-build nixos -I nixos-config=machines/banach.nix -A config.system.build.sdImage
# See https://nixos.wiki/wiki/NixOS_on_ARM#Raspberry_Pi_3

{
  imports = [
    ../../profiles/base.nix
  ];

  #nixpkgs.localSystem = { system = "aarch64-linux"; } // (import <nixpkgs/lib>).systems.examples.aarch64-multiplatform;
  nixpkgs.localSystem = { system = "aarch64-linux"; config = "aarch64-unknown-linux-gnu"; }; # The above one should work but doesn't
  #nixpkgs.crossSystem = { system = "aarch64-linux"; config = "aarch64-unknown-linux-gnu"; };

  networking.hostName = "banach";

  networking.wireless.enable = true;

  # Disable docs
  documentation.nixos.enable = false;
  documentation.man.enable = false;
  documentation.info.enable = false;
}
