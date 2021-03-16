{ config, pkgs, lib, ... }:
{
  # Ensure ethernet is available before mounting
  boot.initrd.network.enable = true;

  # Don't shut down network after initrd, we need it since we network mount /nix/store
  boot.initrd.network.flushBeforeStage2 = false; # TODO: This causes it to have two IP addresses...

  fileSystems."/nix/store" = {
    device = "192.168.5.1:/nix/store";
    fsType = "nfs";
    options = [ "ro" "port=2049" "nolock" "proto=tcp" ];
  };
}
