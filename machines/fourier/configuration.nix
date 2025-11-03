{ config, pkgs, ... }:

let
  my_kodi = pkgs.kodi-gbm.withPackages (p: with p; [
  #my_kodi = pkgs.kodi-wayland.withPackages (p: with p; [
    jellyfin
    invidious
    youtube
    steam-controller
  ]);
in
{
  imports = [
    ../../profiles/personal.nix
    ../../profiles/dns.nix
    ../../profiles/interactive.nix
    ../../profiles/zerotier.nix
  ];

  system.stateVersion = "23.11";

  networking.hostName = "fourier";
  networking.hostId = "e1feebf3";

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  networking.networkmanager.enable = true;

  services.fwupd.enable = true; # Firmware updates

  services.libinput.enable = true;

  theme.fontSize = 14;

  # HW Accelerated video decoding
  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  };
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  environment.variables = {
    LIBVA_DRIVER_NAME="iHD";
  };

  nixpkgs.config.chromium.commandLineArgs = "--enable-features=AcceleratedVideoDecodeLinuxGL";

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  services.pulseaudio.package = pkgs.pulseaudioFull;

  # Kodi
  networking.firewall.allowedTCPPorts = [ 8080 ];
  networking.firewall.allowedUDPPorts = [ 8080 ];
  users.users.kodi = {
    isNormalUser = true;
    extraGroups = [ "input" "video" "audio" ];
  };

  systemd.services.kodi = {
    wantedBy = [ "multi-user.target" ];
    conflicts = [ "getty@tty1.service" ];
    serviceConfig = {
      User = "kodi";
      Group = "users";
      SupplementaryGroups = [ "video" "input" ];
      TTYPath = "/dev/tty1";
      StandardInput = "tty";
      StandardOutput = "journal";
      ExecStart = "${my_kodi}/bin/kodi-standalone";
    };
  };
}
