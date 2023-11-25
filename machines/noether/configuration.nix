# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

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
  hardware.nvidia-jetpack.firmware.autoUpdate = true;
  services.nvpmodel.profileNumber = 0;

  # Avoid kernel crashes
  boot.kernelParams = [ "initcall_blacklist=tegra_se_module_init" ];

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
    extraGroups = [ "input" "video" "audio" ];
  };

  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "kodi";
  services.xserver.enable = true;
  #services.xserver.desktopManager.xfce.enable = true;
  services.xserver.desktopManager.kodi.enable = true;
  services.xserver.desktopManager.kodi.package = my_kodi;
  #services.xserver.desktopManager.retroarch.enable = true;

  # TODO: Figure out why seat0 has CanGraphical=false
  services.xserver.displayManager.lightdm.extraConfig = ''
    logind-check-graphical = false
  '';

  # Disable DPMS
  services.xserver.monitorSection = ''
    Option "DPMS" "true"
  '';

#  services.cage = {
#    enable = true;
#    user = "kodi";
#    program = "${my_kodi}/bin/kodi-standalone";
#  };
#  hardware.nvidia-jetpack.modesetting.enable = true;

  users.users.nixbuilder = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDlZYgyRN9jAt8dPaO7+Kbet20UlOYTtmlTHlVLo7z3HXIT/Qv3HO0hECxln2VmaibosQS1PQrX8r0hRT7ODlV0gLI1aMLX4qARJ1S6Mh+z+vmQUVQFW0Qw01uyF8S0kJEpsIQcpUgg/l1CZ5mZU1G6qcMzaJWJ5Ofn52bWJE2boaXD3qxdP+3NdXSMYcwA/9xXZnMGiR1qb6l6+uI8EcSWwyd3qDn2lR1F2zpWcghVIY5BszL0Sd1fo3y2ENT3dGZbtN/j8HAnO1l4ERy8NdJn9yIFkiqg3iI1TSR5cdCmQ9T6AX21Zk8utfFRWdqMEvlKALx8z16XqoecSYpHzQF50P15KaEFT+Gucg5q7Jg1rSn59t5bOef17D1cvoGi2isd4vmBdf0RVeanz98iTX5BnQGXieCWBOUUEj/Lo4ynrdzMrNwCBi5lKQgrL6aKPrCAFHnqZhMkkj9TxbrG30ySpdr76yYh76xQRDwGLrOa35dksNjz1Iu47hob1ZbZJf8= nixbuilder@noether" ];
  };
  nix.settings.trusted-users = [ "nixbuilder" ];
}

