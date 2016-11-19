{ theme }:

{ config, pkgs, lib, ... }:
{
  services.xserver = {
    enable = true;
    xkbOptions = "compose:ralt";


    windowManager = {
      default = "my-bspwm";

      session = [ rec {
        name = "my-bspwm";

        bspwmConfig = pkgs.writeScript "bspwmrc" ''
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

          ${pkgs.bspwm}/bin/bspc monitor -d • • • • •

          ${pkgs.bspwm}/bin/bspc rule -a Gimp desktop=^8 follow=on floating=on
          ${pkgs.bspwm}/bin/bspc rule -a mplayer2 floating=on

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
        start = ''
          (${pkgs.xorg.xrdb}/bin/xrdb -merge "${pkgs.base16}/xresources/base16-${theme.name}.dark.256.xresources") &
          (${pkgs.xorg.xsetroot}/bin/xsetroot -cursor_name left_ptr) &
          (${pkgs.emacs}/bin/emacs --daemon && ${pkgs.emacs}/bin/emacsclient -c) &
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
      source-code-pro
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

    zathura
    mendeley
    chromium
  ]);

  environment.variables = {
    BROWSER = "chromium";
    GTK_IM_MODULE = "xim"; # For compose key
    QT_IM_MODULE = "xim";

    BSPWM_SOCKET = "/run/user/$UID/bspwm-socket"; # TODO: Include X display number to make unique
  };
}
