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
    w3m

    pythonPackages.glances
    nethogs
    iotop
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
}
