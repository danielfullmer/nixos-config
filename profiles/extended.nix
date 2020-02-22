{ config, pkgs, lib, ... }:
{
  environment.systemPackages = (with pkgs; [
    nox
    nix-index
    vulnix
    morph

    emacs
    pandoc
    weechat
    mutt
    taskwarrior

    gmailieer
    alot
    notmuch
    #notmuch-bower
    astroid
    w3m

    pythonPackages.glances
    bandwhich
    iotop

    qutebrowser
    youtube-dl

    jq
    tig

    kdeconnect
  ]);

  programs.fish = {
    enable = false;
    interactiveShellInit =
      let shellThemeScript = pkgs.writeScript "shellTheme"
        (import (../modules/theme/templates + "/shell.${config.theme.brightness}.nix") { colors=config.theme.colors; });
      in
      ''
        eval sh ${shellThemeScript}
      '';
  };

  services.xserver.desktopManager.extraSessionCommands = ''
    ${pkgs.kdeconnect}/lib/libexec/kdeconnectd &
    ${pkgs.kdeconnect}/bin/kdeconnect-indicator &
  '';

  # KDE Connect
  networking.firewall.allowedTCPPortRanges = [ { from=1714; to=1764; } ];
  networking.firewall.allowedUDPPortRanges = [ { from=1714; to=1764; } ];

  environment.etc."chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json".source = "${pkgs.plasma-browser-integration}/etc/chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json";
}
