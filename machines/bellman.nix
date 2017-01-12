{ config, lib, pkgs, ... }:

rec {
  imports = [
    ../profiles/base.nix
    ../profiles/yubikey.nix
    ../profiles/syncthing.nix
    ../profiles/desktop/default.nix
    ../profiles/autologin.nix
    ../profiles/gaming.nix
    ../profiles/academic.nix
    ../profiles/postfix.nix
    ../profiles/gdrive.nix
    ../profiles/homedir.nix
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ata_piix" "usbhid" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ boot.kernelPackages.rtl8812au ];
  hardware.enableAllFirmware = true;  # For any other wifi firmware

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/f6000fab-5ae0-4e96-b645-fcaa0f1ea781";
      fsType = "btrfs";
      options = [ "ssd" "discard" "compress=lzo" "autodefrag" ];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/5071-EF38";
      fsType = "vfat";
    };
  };

  nix.maxJobs = 4;
  nix.buildCores = 8;

  boot.loader.systemd-boot.enable = true;

  networking.hostName = "bellman"; # Define your hostname.
  networking.hostId = "f6bb12be";
  #networking.wireless.enable = true;
  networking.networkmanager.enable = true;

  services.acpid.enable = true;

  # Use AMDGPU support. Needs kernel >=4.6.
  boot.kernelPackages = pkgs.linuxPackages_4_9;
  boot.kernelPatches = [ {
    name = "amdgpu-config";
    patch = "";
    # Support for Sea Island (Hawaii, 390x) and Southern island (7970) w/ kernel 4.9.
    extraConfig = ''
      DRM_AMDGPU_CIK y
      DRM_AMDGPU_SI y
    '';
  } ];
  boot.kernelParams = [ "amdgpu.exp_hw_support=1" "amdgpu.audio=0" ];
  #services.xserver.videoDrivers = [ "amdgpu-pro" ];
  services.xserver.videoDrivers = [ "amdgpu" ];

  # For Seiki 4K monitor
  # TODO: Add modeline for 1080p at 120Hz
  fonts.fontconfig.dpi = 115;
  fonts.fontconfig.subpixel.rgba = "bgr";
  services.xserver.monitorSection = ''
    DisplaySize 698 393
  '';
  theme.fontSize = 12;
}
