{ config, pkgs, lib, ... }:
{
  services.xserver.displayManager.lightdm.autoLogin = {
    enable = true;
    user = "danielrf";
  };
}
