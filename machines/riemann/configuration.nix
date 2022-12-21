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

  boot.kernelPackages = pkgs.linuxPackages_6_0; # For wifi support.
  nixpkgs.config.allowBroken = true; # For ZFS with kernel 6.0
  boot.kernelParams = [ "mem_sleep_default=deep" "nvme.noacpi=1" ];
  services.fprintd.enable = true; # Fingerprint support
  services.fwupd.enable = true; # Firmware updates

  services.xserver.libinput.enable = true;

  theme.fontSize = 14;

  # HW Accelerated video decoding
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  environment.variables = {
    LIBVA_DRIVER_NAME="iHD";
  };

  nixpkgs.config.chromium.commandLineArgs = "--enable-features=VaapiVideoDecoder --use-gl=egl";

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;

  programs.captive-browser.enable = true;
  programs.captive-browser.interface = "wlp170s0";

  services.redshift.enable = true;
}
