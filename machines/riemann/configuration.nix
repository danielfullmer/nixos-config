{ config, pkgs, lib, ... }:

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

  theme.fontSize = 16;

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
  services.pulseaudio.package = pkgs.pulseaudioFull;

  programs.captive-browser.enable = true;
  programs.captive-browser.interface = "wlp1s0";

  services.redshift.enable = true;

  services.upower.enable = true;

  # 0x0f is DisplayPort cable
  services.xserver.windowManager.i3.config = ''
    bindsym $mod+Shift+d exec ${pkgs.ddcutil}/bin/ddcutil -l "DELL U3821DW" setvcp 60 0x0f
  '';
  environment.systemPackages = with pkgs; [ ddcutil ];
  boot.kernelModules = [ "i2c-dev" ];
  services.udev.packages = lib.singleton (pkgs.writeTextFile {
    name = "ddc-i2c-udev-rules";
    destination = "/etc/udev/rules.d/51-ddc-i2c-custom.rules";
    text = ''
      SUBSYSTEM=="i2c-dev", DRIVERS=="amdgpu", TAG+="uaccess"
    '';
  });
}
