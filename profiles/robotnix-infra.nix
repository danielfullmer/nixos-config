{ config, pkgs, lib, ... }:

let
  mirrors = {
    "https://android.googlesource.com" = "/nix/mirror/aosp";
    "https://github.com/LineageOS" = "/nix/mirror/lineageos/LineageOS";
    "https://github.com/TheMuppets" = "/mnt/cache/muppets/TheMuppets";
  };
in
{
  nix.envVars.ROBOTNIX_GIT_MIRRORS = lib.concatStringsSep "|" (lib.mapAttrsToList (local: remote: "${local}=${remote}") mirrors);

  nix.sandboxPaths = lib.attrValues mirrors;
}
