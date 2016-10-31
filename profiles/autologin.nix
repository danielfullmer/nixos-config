{ config, pkgs, lib, ... }:
{
  services.xserver.displayManager.slim = {
    enable = true;
    autoLogin = true;
    defaultUser = "danielrf";
  };
}
