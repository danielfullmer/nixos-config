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
  boot.initrd.kernelModules = [ "bcache" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ boot.kernelPackages.rtl8812au ];
  hardware.enableAllFirmware = true;  # For any other wifi firmware

  # NOTE: Using bcache + LVM
  # bcache on: ata-ST2000DM006-2DM164_W4Z4BH2E-part2 and ata-WDC_WD5000AAKS-22TMA0_WD-WCAPW3279067
  # bcache ssd is: ata-OCZ-AGILITY4_OCZ-CS8UXT0MD692SSR2
  # LVM on top of each of those, combined into a single volume group
  # Try to move windows off of faster 500gb SSD, and then switch to that one.
  fileSystems = {
    "/" = {
      device = "/dev/mapper/VolGroup0-main";
      fsType = "btrfs";
      options = [ "compress" ];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/3AF1-2802";
      fsType = "vfat";
    };
  };

  swapDevices = [ { device = "/dev/mapper/VolGroup0-swap"; } ];

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
  boot.kernelParams = [ "amdgpu.exp_hw_support=1" "amdgpu.audio=0" ];
  #services.xserver.videoDrivers = [ "amdgpu-pro" ];
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Enable vulkan support
  # Test with "vulkaninfo"
  nixpkgs.config.packageOverrides = (p: {
    mesa_drivers = (p.mesa_noglu.override { enableRadv=true; }).drivers;
  });
  environment.systemPackages = [ pkgs.vulkan-loader ];

  services.xserver.deviceSection = ''
    Option "DRI3" "1"
    Option "TearFree" "on"
  '';

  # For Seiki 4K monitor
  # TODO: Add modeline for 1080p at 120Hz
  fonts.fontconfig.dpi = 115;
  fonts.fontconfig.subpixel.rgba = "bgr";
  services.xserver.monitorSection = ''
    DisplaySize 698 393
  '';
  theme.fontSize = 12;
}
