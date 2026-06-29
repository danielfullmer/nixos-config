{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ../../profiles/personal.nix
      ../../profiles/dns.nix
      ../../profiles/interactive.nix
      ../../profiles/extended.nix
      #../../profiles/zerotier.nix
      #../../profiles/yubikey.nix
    ];

  hardware.nvidia-jetpack = {
    enable = true;
    som = "thor-agx";
    carrierBoard = "devkit";
    firmware.autoUpdate = true;
    configureCuda = true;
  };

  services.nvpmodel.profileNumber = 0;

  hardware.graphics.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "hilbert"; # Define your hostname.
  networking.hostId = "548a95e6";
  # Pick only one of the below networking options.
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
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

  hardware.bluetooth.enable = true;

  environment.systemPackages = with pkgs; [ wget git ];

  services.openssh.enable = true;


  system.stateVersion = "26.05";

  ###

  services.pipewire.enable = true;

  users.users.kodi = {
    isNormalUser = true;
    extraGroups = [ "input" "video" "audio" ];
  };

  hardware.nvidia-jetpack.modesetting.enable = true;
  users.users.nixbuilder = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDlZYgyRN9jAt8dPaO7+Kbet20UlOYTtmlTHlVLo7z3HXIT/Qv3HO0hECxln2VmaibosQS1PQrX8r0hRT7ODlV0gLI1aMLX4qARJ1S6Mh+z+vmQUVQFW0Qw01uyF8S0kJEpsIQcpUgg/l1CZ5mZU1G6qcMzaJWJ5Ofn52bWJE2boaXD3qxdP+3NdXSMYcwA/9xXZnMGiR1qb6l6+uI8EcSWwyd3qDn2lR1F2zpWcghVIY5BszL0Sd1fo3y2ENT3dGZbtN/j8HAnO1l4ERy8NdJn9yIFkiqg3iI1TSR5cdCmQ9T6AX21Zk8utfFRWdqMEvlKALx8z16XqoecSYpHzQF50P15KaEFT+Gucg5q7Jg1rSn59t5bOef17D1cvoGi2isd4vmBdf0RVeanz98iTX5BnQGXieCWBOUUEj/Lo4ynrdzMrNwCBi5lKQgrL6aKPrCAFHnqZhMkkj9TxbrG30ySpdr76yYh76xQRDwGLrOa35dksNjz1Iu47hob1ZbZJf8= nixbuilder@noether" ];
  };
  nix.settings.trusted-users = [ "nixbuilder" ];

#  virtualisation.podman = {
#    enable = true;
#    enableNvidia = true;
#  };

  hardware.graphics.enable32Bit = lib.mkForce false;
}
