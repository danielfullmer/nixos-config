{ config, pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [ kdeconnect ];

  services.xserver.desktopManager.extraSessionCommands = ''
    ${pkgs.kdeconnect}/lib/libexec/kdeconnectd &
    ${pkgs.kdeconnect}/bin/kdeconnect-indicator &
  '';

  # KDE Connect
  networking.firewall.allowedTCPPortRanges = [ { from=1714; to=1764; } ];
  networking.firewall.allowedUDPPortRanges = [ { from=1714; to=1764; } ];

  environment.etc."chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json".source = "${pkgs.plasma-browser-integration}/etc/chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json";
}
