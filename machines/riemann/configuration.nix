{ config, pkgs, ... }:

{
  imports = [
    ../../profiles/personal.nix
    ../../profiles/dns.nix
    ../../profiles/interactive.nix
    ../../profiles/extended.nix
    ../../profiles/zerotier.nix
    ../../profiles/yubikey.nix
    ../../profiles/desktop/default.nix
    ../../profiles/gaming.nix
    ../../profiles/noether-remote-builder.nix
  ];

  system.stateVersion = "22.05";

  networking.hostName = "riemann";
  networking.hostId = "e1feebf3";

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  networking.networkmanager.enable = true;

  programs.light.enable = true;

  services.fprintd.enable = true; # Fingerprint support
  services.fwupd.enable = true; # Firmware updates

  services.xserver.libinput.enable = true;

  theme.fontSize = 14;

  # HW Accelerated video decoding
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  environment.variables = {
    LIBVA_DRIVER_NAME="radeonsi";
  };

  nixpkgs.config.chromium.commandLineArgs = "--enable-features=VaapiVideoDecoder";

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;

  programs.captive-browser.enable = true;
  programs.captive-browser.interface = "wlp1s0";

  services.redshift.enable = true;
}
