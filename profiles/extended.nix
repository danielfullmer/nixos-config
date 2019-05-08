{ config, pkgs, lib, ... }:
{
  environment.systemPackages = (with pkgs; [
    nox
    nix-index

    emacs
    pandoc
    bitlbee
    weechat
    mutt
    taskwarrior

    gmailieer
    alot
    notmuch
    notmuch-bower
    astroid
    w3m

    pythonPackages.glances
    nethogs
    iotop

    qutebrowser
    youtube-dl

    jq
    tig

    kdeconnect
  ]);

  programs.fish = {
    enable = true;
    interactiveShellInit =
      let shellThemeScript = pkgs.writeScript "shellTheme"
        (import (../modules/theme/templates + "/shell.${config.theme.brightness}.nix") { colors=config.theme.colors; });
      in
      ''
        eval sh ${shellThemeScript}
      '';
  };

  # If the host is big enough to use all those packages, it can probably handle zrap swap and tmpfs
  zramSwap.enable = true;
  #boot.tmpOnTmpfs = true; # XXX: Building big programs doesn't work so hot with this.

  services.xserver.desktopManager.extraSessionCommands = ''
    ${pkgs.kdeconnect}/lib/libexec/kdeconnectd &
    ${pkgs.kdeconnect}/bin/kdeconnect-indicator &
  '';

  environment.etc."chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json".source = "${pkgs.plasma-browser-integration}/etc/chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json";
}
