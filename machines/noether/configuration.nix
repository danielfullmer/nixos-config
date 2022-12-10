# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  my_kodi = pkgs.kodi-wayland.withPackages (p: with p; [
    jellyfin
    invidious
    youtube
    steam-controller
  ]);
in
{
  imports =
    [ # Include the results of the hardware scan.
      ../../profiles/personal.nix
      ../../profiles/dns.nix
      ../../profiles/interactive.nix
      ../../profiles/extended.nix
      ../../profiles/zerotier.nix
      ../../profiles/yubikey.nix
    ];

  hardware.nvidia-jetpack.enable = true;
  hardware.nvidia-jetpack.som = "orin-agx";
  hardware.nvidia-jetpack.carrierBoard = "devkit";
  services.nvpmodel.profileNumber = 0;

  hardware.opengl.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "noether"; # Define your hostname.
  networking.hostId = "548a95e6";
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  environment.systemPackages = with pkgs; [ wget git ];

  services.openssh.enable = true;

  # Kodi
  networking.firewall.allowedTCPPorts = [ 8080 ];
  networking.firewall.allowedUDPPorts = [ 8080 ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  system.stateVersion = "22.05";

  ###

  users.users.kodi = {
    isNormalUser = true;
    extraGroups = [ "video" ];
  };

  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "kodi";
  services.xserver.enable = true;
  #services.xserver.desktopManager.xfce.enable = true;
  services.xserver.desktopManager.kodi.enable = true;
  services.xserver.desktopManager.kodi.package = my_kodi;
  #services.xserver.desktopManager.retroarch.enable = true;

  # Disable DPMS
  services.xserver.monitorSection = ''
    Option "DPMS" "true"
  '';

  #services.cage = {
  #  enable = true;
  #  user = "kodi";
  #  program = "${my_kodi}/bin/kodi-standalone";
  #};
}

