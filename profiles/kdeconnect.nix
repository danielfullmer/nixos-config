{ config, pkgs, lib, ... }:
let
  inherit (pkgs.kdePackages) kdeconnect-kde;
in
{
  environment.systemPackages =  [ kdeconnect-kde ];

  systemd.user.services = {
    kdeconnect-indicator = {
      serviceConfig.ExecStart = "${kdeconnect-kde}/bin/kdeconnect-indicator";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
    };
  };

  # KDE Connect
  networking.firewall.interfaces."${config.controlnet.ap.interface}" = {
    allowedTCPPortRanges = [ { from=1714; to=1764; } ];
    allowedUDPPortRanges = [ { from=1714; to=1764; } ];
  };

  environment.etc."chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json".source = "${pkgs.kdePackages.plasma-browser-integration}/etc/chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json";
}
