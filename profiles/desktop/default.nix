{ config, pkgs, lib, ... }:

with lib;

{
  services.xserver = {
    enable = true;
    xkbOptions = "compose:ralt";

    displayManager.lightdm = {
      enable = true;
      background = toString config.theme.background;
    };

    windowManager = {
      default = "i3";
      i3.enable = true;
      i3.config = ''
        # Please see http://i3wm.org/docs/userguide.html for a complete reference!

        # 1 pixel window borders
        new_window pixel 1

        # If only one window visible, hide borders
        hide_edge_borders smart
      '';
      i3.bars = [
        "status_command ${pkgs.i3status}/bin/i3status --config ${./i3status.config}"
      ];
    };

    desktopManager = {
      default = "desktop";
      xterm.enable = false;
      session = [ {
        name = "desktop";
        start =
          let
            xresourcesFile = pkgs.writeText "xresources" config.services.xserver.xresources;
            dunstFile = pkgs.writeText "dunstFile" (generators.toINI {} config.programs.dunst.config);
          in
          ''
          (${pkgs.xorg.xrdb}/bin/xrdb -merge "${xresourcesFile}") &
          (${pkgs.xorg.xmodmap}/bin/xmodmap "${./Xmodmap}") &
          (${pkgs.xorg.xsetroot}/bin/xsetroot -cursor_name left_ptr) &
          (${pkgs.networkmanagerapplet}/bin/nm-applet) &
          (${pkgs.pasystray}/bin/pasystray) &
          (${pkgs.xss-lock}/bin/xss-lock -- ${pkgs.i3lock-fancy}/bin/i3lock-fancy) &
          (${pkgs.feh}/bin/feh --bg-fill ${config.theme.background}) &
          (${pkgs.dunst}/bin/dunst -conf ${dunstFile}) &
          (${pkgs.ibus}/bin/ibus-daemon -d) &
          #(${pkgs.emacs}/bin/emacs --daemon && ${pkgs.emacs}/bin/emacsclient -c) &

          ${config.services.xserver.desktopManager.extraSessionCommands}
        '';
      } ];
    };
  };

  i18n.inputMethod.enabled = "ibus";

  fonts = {
    fonts = (with pkgs; [
      powerline-fonts
      font-awesome-ttf
      corefonts
      lmodern
      #source-code-pro
      roboto
      roboto-mono
      roboto-slab
      noto-fonts
    ]);
  };

  # Disabled to hopefully reduce latency, and since tiling window managers don't use many compositing features anyway.
  #services.compton.enable = true;

  location = {
    latitude = 41.3;
    longitude = -72.9;
  };
  services.redshift = {
    temperature = {
      day = 5500;
      night = 3700;
    };
  };

  hardware.pulseaudio = {
    enable = true;
#    tcp.enable = true;
#    tcp.anonymousClients.allowedIpRanges = [ "30.0.0.0/24" ];
#    zeroconf.discovery.enable = true;
#    zeroconf.publish.enable = true;
  };

  security.rtkit.enable = true;

  environment.systemPackages = (with pkgs; [
    xclip

    dmenu
    (rofi.override { theme=null; }) # config.theme conflicts with this and I can't be bothered to figure out why
    stalonetray
    dunst

    termite
    rxvt_unicode-with-plugins
    st

    mpv

    pavucontrol

    gnome3.gnome_themes_standard
    gnome3.adwaita-icon-theme

    adapta-gtk-theme

    zathura
    chromium
  ]);

  environment.etc."zathurarc".text = config.programs.zathura.config;

  ### THEMES ###
  # Note: Use package "awf" to test gtk themes
  environment.etc."xdg/gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-theme-name = ${config.theme.gtkTheme}
    gtk-icon-theme-name = ${config.theme.gtkIconTheme}
    gtk-font-name = ${config.theme.fontName} ${toString config.theme.fontSize}
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
      gtk-theme-name = "${config.theme.gtkTheme}"
      gtk-icon-theme-name = "${config.theme.gtkIconTheme}"
      gtk-font-name = "${config.theme.fontName} ${toString config.theme.fontSize}"
    ''}:$GTK2_RC_FILES"

    # Set GTK_PATH so that GTK+ can find the theme engines.
    export GTK_PATH="${config.system.path}/lib/gtk-2.0:${config.system.path}/lib/gtk-3.0"

    # Set GTK_DATA_PREFIX so that GTK+ can find the Xfce themes.
    export GTK_DATA_PREFIX=${config.system.path}

    # SVG loader for pixbuf (needed for GTK svg icon themes)
    export GDK_PIXBUF_MODULE_FILE=$(echo ${pkgs.librsvg.out}/lib/gdk-pixbuf-2.0/*/loaders.cache)
  '';

  programs.browserpass.enable = true;

  environment.variables = {
    BROWSER = "chromium";
  };

  # HW accelerated video playback
  environment.variables.MPV_HOME = "/etc/mpv";
  environment.etc."mpv/mpv.conf".text = ''
    hwdec=auto
  '';

  # This is a user-specific hack since it is not trivial to replace the
  # internal Compose file under ${xlibs.libX11}/share/X11/locale/*/Compose
  # without rebuilding lots of stuff
  system.activationScripts = {
    xcompose = let
      # See example at https://github.com/kragen/xcompose
      XComposeFile = pkgs.writeTextFile {
        name = "XCompose";
        text = import ./XCompose.nix { inherit pkgs; };
      };
    in
    lib.stringAfter [ "users" ]
    ''
      ln -fs ${XComposeFile} /home/danielrf/.XCompose
    '';
  };
}
