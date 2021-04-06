{ config, pkgs, lib, ... }:
{
  services.xserver.displayManager.autoLogin = {
    enable = true;
    user = "danielrf";
  };
}
