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
  boot.tmpOnTmpfs = true;
}
