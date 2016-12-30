{ config, pkgs, lib, ... }:
{
  environment.systemPackages = (with pkgs; [
    qemu
    win-qemu
    virtmanager
  ]);

  virtualisation.libvirtd.enable = true;
}
