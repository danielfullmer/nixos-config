{ config, lib, pkgs, ... }:

let
  theme = (import ../profiles/theme.nix {});
in
{
  imports = [
    (import ../profiles/base.nix { inherit theme; })
    ../profiles/yubikey.nix
    ../profiles/syncthing.nix
    (import ../profiles/desktop.nix { inherit theme; })
    ../profiles/autologin.nix
    ../profiles/gaming.nix
    ../profiles/academic.nix
    ../profiles/qemu-kvm.nix
    ../profiles/postfix.nix
    ../profiles/homedir.nix
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ata_piix" "usbhid" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ pkgs.linuxPackages_latest.rtl8812au ];
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
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPatches = [ {
    name = "amdgpu-config";
    patch = "";
    # Sea Island (Hawaii, 390x) support. TODO: Add southern island (7970) support w/ kernel 4.9. "DRM_AMDGPU_SI y"
    extraConfig = "DRM_AMDGPU_CIK y";
  } ];
  boot.kernelParams = [ "amdgpu.exp_hw_support=1" ];
  services.xserver.videoDrivers = [ "amdgpu" ];
}
