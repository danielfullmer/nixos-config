{ theme }:

{ config, pkgs, lib, ... }:
{
  services.xserver = {
    enable = true;
    xkbOptions = "compose:ralt";


    windowManager = {
      #default = "my-bspwm";
      default = "i3";

      i3.enable = true;
      i3.configFile = pkgs.writeTextFile {
        name = "i3config";
        text = import ./i3config.nix { inherit pkgs theme; };
      };

      session = [ rec {
        name = "my-bspwm";

        bspwmConfig =
          let bspwmTheme = pkgs.writeTextFile {
              name = "bspwmTheme";
              text = import (../../pkgs/bspwm + "/theme.${theme.brightness}.nix") { bspwm=pkgs.bspwm; colors=theme.colors; };
            };
          in
        pkgs.writeScript "bspwmrc" ''
          #!/bin/sh
          ${pkgs.bspwm}/bin/bspc config border_width        2
          ${pkgs.bspwm}/bin/bspc config focused_border_color red
          ${pkgs.bspwm}/bin/bspc config presel_border_color green
          ${pkgs.bspwm}/bin/bspc config window_gap          3
          ${pkgs.bspwm}/bin/bspc config top_padding         -3
          ${pkgs.bspwm}/bin/bspc config bottom_padding      -3
          ${pkgs.bspwm}/bin/bspc config left_padding        -3
          ${pkgs.bspwm}/bin/bspc config right_padding       -3
          ${pkgs.bspwm}/bin/bspc config split_ratio         0.52
          ${pkgs.bspwm}/bin/bspc config borderless_monocle  true
          ${pkgs.bspwm}/bin/bspc config gapless_monocle     true

          for name in `bspc query -M`; do
            ${pkgs.bspwm}/bin/bspc monitor $name -d • • • •
          done

          ${pkgs.bspwm}/bin/bspc rule -a Gimp desktop=^8 follow=on floating=on
          ${pkgs.bspwm}/bin/bspc rule -a mplayer2 floating=on

          source ${bspwmTheme}

          # This needs to happen after the bspc's above
          ${import ./panel/panel.nix { inherit pkgs theme; }}
        '';

        start = ''
          ${pkgs.sxhkd}/bin/sxhkd &
          ${pkgs.bspwm}/bin/bspwm -c ${bspwmConfig} &
          waitPID=$!
        '';
      } ];
    };

    desktopManager = {
      default = "desktop";
      xterm.enable = false;
      session = [ {
        name = "desktop";
        start =
          let xresourcesFile = pkgs.writeTextFile {
              name = "xresources";
              text = import (../../pkgs/xresources + "/theme.${theme.brightness}.nix") { colors=theme.colors; };
            };
          in
          ''
          (${pkgs.xorg.xrdb}/bin/xrdb -merge "${xresourcesFile}") &
          (${pkgs.xorg.xmodmap}/bin/xmodmap "${./Xmodmap}") &
          (${pkgs.xorg.xsetroot}/bin/xsetroot -cursor_name left_ptr) &
          (${pkgs.networkmanagerapplet}/bin/nm-applet) &
          (${pkgs.pasystray}/bin/pasystray) &
          #(${pkgs.emacs}/bin/emacs --daemon && ${pkgs.emacs}/bin/emacsclient -c) &
        '';
      } ];
    };
  };

  fonts = {
    fontconfig = {
      enable = true;
      ultimate.preset = "ultimate4";
      ultimate.substitutions = "combi";
    };
    fonts = (with pkgs; [
      powerline-fonts
      font-awesome-ttf
      corefonts
      dejavu_fonts
      lmodern
      #source-code-pro
      roboto
    ]);
  };

  services.redshift = {
    enable = true;
    latitude = "41";
    longitude = "-73";
      temperature = {
        day = 5500;
        night = 3700;
      };
  };

  hardware.pulseaudio = {
    enable = true;
    tcp.enable = true;
    tcp.anonymousClients.allowedIpRanges = [ "30.0.0.0/24" ];
    zeroconf.discovery.enable = true;
    zeroconf.publish.enable = true;
  };

  security.rtkit.enable = true;

  environment.systemPackages = (with pkgs; [
    bspwm

    compton
    xclip

    dmenu
    rofi
    stalonetray

    termite
    rxvt_unicode-with-plugins
    st

    pavucontrol

    gnome3.gnome_themes_standard
    gnome3.adwaita-icon-theme

    adapta-gtk-theme

    zathura
    mendeley
    google-chrome
  ]);

  environment.etc."zathurarc".text = import (../../pkgs/zathura + "/theme.${theme.brightness}.nix") { colors=theme.colors; };

  ### THEMES ###
  # Note: Use package "awf" to test gtk themes
  environment.etc."xdg/gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-theme-name = ${theme.gtkTheme}
    gtk-icon-theme-name = ${theme.gtkIconTheme}
    gtk-font-name = ${theme.fontName} ${toString theme.fontSize}
  '';

  # Theme script inspired by bennofs/etc-nixos in desktop.nix
  environment.extraInit = ''
    # Remove local user overrides (for determinism, causes hard to find bugs)
    rm -f ~/.config/gtk-3.0/settings.ini ~/.config/Trolltech.conf

    # GTK3: add /etc/xdg/gtk-3.0 to search path for settings.ini
    # We use /etc/xdg/gtk-3.0/settings.ini to set the icon and theme name for GTK 3
    export XDG_CONFIG_DIRS="/etc/xdg:$XDG_CONFIG_DIRS"

    # GTK2 theme + icon theme
    export GTK2_RC_FILES="${pkgs.writeText "gtkrc2Theme" ''
      gtk-theme-name = "${theme.gtkTheme}"
      gtk-icon-theme-name = "${theme.gtkIconTheme}"
      gtk-font-name = "${theme.fontName} ${toString theme.fontSize}"
    ''}:$GTK2_RC_FILES"

    # Set GTK_PATH so that GTK+ can find the theme engines.
    export GTK_PATH="${config.system.path}/lib/gtk-2.0:${config.system.path}/lib/gtk-3.0"

    # Set GTK_DATA_PREFIX so that GTK+ can find the Xfce themes.
    export GTK_DATA_PREFIX=${config.system.path}

    # SVG loader for pixbuf (needed for GTK svg icon themes)
    export GDK_PIXBUF_MODULE_FILE=$(echo ${pkgs.librsvg.out}/lib/gdk-pixbuf-2.0/*/loaders.cache)
  '';

  environment.variables = {
    BROWSER = "google-chrome-stable";
    GTK_IM_MODULE = "xim"; # For compose key
    QT_IM_MODULE = "xim";

    BSPWM_SOCKET = "/run/user/$UID/bspwm-socket"; # TODO: Include X display number to make unique
  };
}
