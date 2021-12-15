{ config, pkgs, ... }:

{
  imports = [
    ../../profiles/base.nix
    ../../profiles/dns.nix
    ../../profiles/interactive.nix
    ../../profiles/extended.nix
    ../../profiles/zerotier.nix
    ../../profiles/yubikey.nix
    ../../profiles/desktop/default.nix
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

  boot.kernelPackages = pkgs.linuxPackages_latest; # For wifi support
  boot.kernelParams = [ "mem_sleep_default=deep" ];
  services.fprintd.enable = true; # Fingerprint support
  services.fwupd.enable = true; # Firmware updates

  services.xserver.libinput.enable = true;

  theme.fontSize = 8;

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
}
