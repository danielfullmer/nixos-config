{ config, pkgs, lib, ... }:
{
  services.hydra = {
    enable = true;
    hydraURL = "http://${config.networking.hostName}:3000/";
    notificationSender = "cgibreak@gmail.com";
    smtpHost = "${config.networking.hostName}";
    useSubstitutes = true;
    buildMachinesFiles = [ ./hydra-remote-machines ];
  };
}
