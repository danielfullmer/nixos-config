{ config, pkgs, lib, ... }:
{
  services.displayManager.autoLogin = {
    enable = true;
    user = "danielrf";
  };
}
