{ config, pkgs, lib, ... }:
{
  virtualisation.virtualbox.guest.enable = true;

  # remove the fsck that runs at startup. It will always fail to run, stopping
  # your boot until you press *. 
  boot.initrd.checkJournalingFS = false;
}
