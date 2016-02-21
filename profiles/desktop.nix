{ config, pkgs, lib, ... }:
{
  services.xserver = {
    enable = true;
    xkbOptions = "compose:ralt";

    displayManager = {
      slim = {
        enable = true;
        autoLogin = true;
        defaultUser = "danielrf";
      };

      sessionCommands = ''
        ${pkgs.xorg.xrdb}/bin/xrdb -merge "$HOME/.base16-xresources/base16-tomorrow.dark.256.xresources"
      '';
    };

    windowManager = {
      default = "bspwm";
      bspwm.enable = true;
    };

    desktopManager = {
      default = "none";
      xterm.enable = false;
    };
  };

  fonts.fonts = (with pkgs; [
    powerline-fonts
    font-awesome-ttf
    corefonts
    dejavu_fonts
    lmodern
  ]);

  services.redshift = {
    enable = true;
    latitude = "41";
    longitude = "-73";
      temperature = {
        day = 5500;
        night = 3700;
      };
  };

  nixpkgs.config.vim.gui = "auto";

  hardware.pulseaudio.enable = true;
  security.rtkit.enable = true;

  environment.systemPackages = (with pkgs; [
    compton
    xclip

    dmenu
    rofi
    stalonetray

    # Panel-related
    bar-xft
    conky
    xtitle

    termite
    rxvt_unicode-with-plugins

    pavucontrol

    gnome3.gnome_themes_standard
    gnome3.adwaita-icon-theme

    zathura
    mendeley
    chromiumBeta
  ]);

  environment.variables = {
    BROWSER = "chromium";
    GTK_IM_MODULE = "xim"; # For compose key
    QT_IM_MODULE = "xim";
  };
}
