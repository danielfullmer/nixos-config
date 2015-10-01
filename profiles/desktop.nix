{ config, pkgs, lib, ... }:
{
  services.xserver = {
    enable = true;
    displayManager.slim.enable = true;
    displayManager.slim.autoLogin = true;
    displayManager.slim.defaultUser = "danielrf";
    displayManager.sessionCommands = "sh $HOME/.xinitrc";
    desktopManager.xterm.enable = false;
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
    xlibs.xdpyinfo

    xcompmgr
    xsettingsd
    xclip
    trayer
    dmenu
    libnotify
    conky

    rxvt_unicode-with-plugins

    gnome3.gnome_themes_standard
    gnome3.adwaita-icon-theme

    zathura
    chromiumBeta
  ]);
}
