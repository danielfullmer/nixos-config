{ config, pkgs, lib, ... }:
{
  environment.systemPackages = (with pkgs; [
    nox
    nix-index
    #vulnix
    morph

    emacs
    weechat
    mutt

    w3m

    glances
    #bandwhich
    iotop

    youtube-dl

    jq
    tig
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
}
