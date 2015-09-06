{ config, pkgs, lib, ... }:
{
  services.xserver = {
    enable = true;
    displayManager.slim.enable = true;
    displayManager.slim.autoLogin = true;
    displayManager.slim.defaultUser = "danielrf";
    displayManager.sessionCommands = "sh $HOME/.xinitrc";
    desktopManager.xterm.enable = false;
    windowManager.bspwm.enable = true;
  };

  nixpkgs.config.vim.gui = "auto";

  hardware.pulseaudio.enable = true;
  security.rtkit.enable = true;

  environment.systemPackages = (with pkgs; [
    bspwm
    sxhkd

    xlibs.xmodmap
    xlibs.xrdb
    xlibs.xset
    xlibs.xsetroot

    xcompmgr
    xsettingsd
    trayer
    dmenu

    gnome3.gnome_keyring

    rxvt_unicode

    chromiumBeta
  ]);

  fonts.fonts = (with pkgs; [
    powerline-fonts
  ]);
}
