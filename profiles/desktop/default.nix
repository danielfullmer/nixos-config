{ config, pkgs, lib, ... }:

with lib;

{
  services.xserver = {
    enable = true;
    xkbOptions = "compose:ralt";
    libinput.touchpad.naturalScrolling = true;

    displayManager.defaultSession = "none+i3";
    displayManager.lightdm = {
      enable = true;
      background = toString config.theme.background;
    };

    windowManager = {
      i3.enable = true;
      i3.config = ''
        # Please see http://i3wm.org/docs/userguide.html for a complete reference!

        # 1 pixel window borders
        new_window pixel 3

        # If only one window visible, hide borders
        hide_edge_borders smart

        set $ws1 "1"
        set $ws2 "2"
        set $ws3 "3"
        set $ws4 "4"
        set $ws5 "5"
        set $ws6 "6"
        set $ws7 "7"
        set $ws8 "8"
        set $ws9 "9"
        set $ws10 "10"
      '';
      i3.status.config = builtins.readFile ./i3status.config;
      i3.status.order = [
        "cpu_usage"
        "memory"
        "disk /"
        "load"
        "tztime local"
      ];
    };

    desktopManager = {
      xterm.enable = false;
    };
  };

  services.picom = {
    #enable = true;
    fade = true;
    fadeDelta = 5;
    vSync = true;
  };

  systemd.user.services = mkMerge [
    (mapAttrs (n: v: v // { wantedBy = [ "graphical-session.target" ]; partOf = [ "graphical-session.target" ]; }) {
    xrdb.serviceConfig.ExecStart = let
        xresourcesFile = pkgs.writeText "xresources" config.services.xserver.xresources;
      in
        "${pkgs.xorg.xrdb}/bin/xrdb -merge \"${xresourcesFile}\"";
    xrdb.serviceConfig.Type = "oneshot";

    xmodmap.serviceConfig.ExecStart = "${pkgs.xorg.xmodmap}/bin/xmodmap \"${./Xmodmap}\"";
    xmodmap.serviceConfig.Type = "oneshot";

    xsetroot.serviceConfig.ExecStart = "${pkgs.xorg.xsetroot}/bin/xsetroot -cursor_name left_ptr";
    xsetroot.serviceConfig.Type = "oneshot";

    xss-lock.serviceConfig.ExecStart = "${pkgs.xss-lock}/bin/xss-lock -- ${pkgs.i3lock-pixeled}/bin/i3lock-pixeled";

    feh.serviceConfig.ExecStart = "${pkgs.feh}/bin/feh --bg-fill ${config.theme.background}";
    feh.serviceConfig.Type = "oneshot";

    dunst.serviceConfig.ExecStart = let
        dunstFile = pkgs.writeText "dunstFile" (generators.toINI {} config.programs.dunst.config);
      in
        "${pkgs.dunst}/bin/dunst -conf ${dunstFile}";

    #(${pkgs.ibus}/bin/ibus-daemon -d) &
    #(${pkgs.emacs}/bin/emacs --daemon && ${pkgs.emacs}/bin/emacsclient -c) &

    pasystray.serviceConfig.ExecStart = "${pkgs.pasystray}/bin/pasystray";
  })
  (mkIf config.networking.networkmanager.enable {
    nm-applet = {
      serviceConfig.ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
    };
  })
  (mkIf config.hardware.bluetooth.enable {
    mpris-proxy = {
      serviceConfig.ExecStart = "${config.hardware.bluetooth.package}/bin/mpris-proxy";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
    };
  })
  ];

  #i18n.inputMethod.enabled = "ibus";

  fonts = {
    packages = (with pkgs; [
      powerline-fonts
      font-awesome
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
    latitude = 31.2;
    longitude = -115.1;
  };
  services.redshift = {
    executable = "/bin/redshift-gtk";
    temperature = {
      day = 6500;
      night = 3700;
    };
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
  environment.etc = {
    "wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
      bluez_monitor.properties = {
        ["bluez5.enable-sbc-xq"] = true,
        ["bluez5.enable-msbc"] = true,
        ["bluez5.enable-hw-volume"] = true,
        ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
      }
    '';
  };
  security.rtkit.enable = true;

  environment.systemPackages = (with pkgs; [
    xclip

    dmenu
    (rofi.override { theme=null; }) # config.theme conflicts with this and I can't be bothered to figure out why
    stalonetray
    dunst

    termite
    st

    mpv

    playerctl
    pulseaudio
    pavucontrol

    gnome.gnome-themes-extra
    gnome.adwaita-icon-theme

    orchis-theme

    zathura
    chromium

    haskellPackages.arbtt
  ]);

  environment.etc."zathurarc".text = config.programs.zathura.config;

  programs.zathura.config = ''
    # Don't horizontally center on search result
    set search-hadjust false
  '';

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

  programs.chromium.enable = true;
  environment.variables = {
    BROWSER = "chromium";
  };

  # HW accelerated video playback
  environment.variables.MPV_HOME = "/etc/mpv";
  environment.etc."mpv/mpv.conf".text = ''
    hwdec=auto-safe
    vo=gpu
    profile=gpu-hq
  '';

  # TODO
  # This is a user-specific hack since it is not trivial to replace the
  # internal Compose file under ${xorg.libX11}/share/X11/locale/*/Compose
  # without rebuilding lots of stuff
#  system.activationScripts = {
#    xcompose = let
#      # See example at https://github.com/kragen/xcompose
#      XComposeFile = pkgs.writeTextFile {
#        name = "XCompose";
#        text = import ./XCompose.nix { inherit pkgs; };
#      };
#    in
#    lib.stringAfter [ "users" ]
#    ''
#      ln -fs ${XComposeFile} /home/danielrf/.XCompose
#    '';
#  };

  services.arbtt.enable = true;
}
