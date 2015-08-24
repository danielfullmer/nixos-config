{ config, pkgs, lib, ... }:
{
  hardware.opengl.driSupport32Bit = true;

  environment.systemPackages = (with pkgs; [
    steam
  ]);
}
