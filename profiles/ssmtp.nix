{ config, pkgs, lib, ... }:
{
  networking.defaultMailServer = {
    directDelivery = true;
    hostName = "bellman";
    root = "cgibreak@gmail.com";
  };
}
