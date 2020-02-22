{ config, pkgs, lib, ... }:

with lib;

{
  services.xserver = {
    enable = true;
    xkbOptions = "compose:ralt";
    libinput.naturalScrolling = true;

    displayManager.defaultSession = "desktop+i3";
    displayManager.lightdm = {
      enable = true;
      background = toString config.theme.background;
    };

    windowManager = {
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
          (${pkgs.xss-lock}/bin/xss-lock -- ${pkgs.i3lock-pixeled}/bin/i3lock-pixeled) &
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

    zathura
    chromium
  ]);

  environment.etc."zathurarc".text = config.programs.zathura.config;

  ### THEMES ###
  gtk = {
    enable = true;
    theme = { name = "Adapta"; package = pkgs.adapta-gtk-theme; };
    iconTheme = { name = "Adwaita"; package = pkgs.gnome3.adwaita-icon-theme; };
  };
  # TODO: Qt theme

  programs.chromium = {
    enable = true;
    extensions = [
      "kcgpggonjhmeaejebeoeomdlohicfhce" # Cookie Remover
      "ihlenndgcmojhcghmfjfneahoeklbjjh" # cVim
      "ldpochfccmkkmhdbclfhpagapcfdljkj" # Decentraleyes
      "cimiefiiaegbelhefglklhhakcgmhkai" # Plasma integration
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
      "pgdnlhfefecpicbbihgmbmffkjpaplco" # uBlock Origin Extra
      "ogfcmafjalglgifnmanfmnieipoejdcf" # uMatrix
      "naepdomgkenhinolocfifgehidddafch" # Browserpass
    ];
    extraOpts = {
      ExtensionInstallForcelist = [
        # Bypass Paywalls: Fite me IRL Google.
        "dcpihecpambacapedldabdbpakmachpb;https://raw.githubusercontent.com/iamadamdev/bypass-paywalls-chrome/master/updates.xml"
      ];
    };
  };

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
