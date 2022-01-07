{ config, pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [ kdeconnect ];

  systemd.user.services = {
    kdeconnect-indicator = {
      serviceConfig.ExecStart = "${pkgs.kdeconnect}/bin/kdeconnect-indicator";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
    };
  };

  # KDE Connect
  networking.firewall.interfaces."${config.controlnet.ap.interface}" = {
    allowedTCPPortRanges = [ { from=1714; to=1764; } ];
    allowedUDPPortRanges = [ { from=1714; to=1764; } ];
  };

  environment.etc."chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json".source = "${pkgs.plasma-browser-integration}/etc/chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json";
}
