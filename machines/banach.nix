{ config, lib, pkgs, ... }:

{
  imports = [
    ../profiles/base.nix
    ../profiles/gdrive.nix
  ];

  theme.base16Color = "isotope";

  system.stateVersion = "17.09";
  nixpkgs.system = "aarch64-linux";

  # Parts of this taken from nixos/modules/installer/cd-dvd/sd-image-aarch64.nix.
  # Bootloader was initially created from that SD image
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  boot.initrd.availableKernelModules = [ "usbhid" ];
  boot.kernelModules = [ ];
  boot.kernelParams = [ "console=ttyS0,115200n8" "console=tty0" ];
  #boot.kernelPackages = pkgs.linuxPackages_rpi; # Includes wireless firmware bcm2710-rpi-3-b.dtb
  boot.kernelPackages = pkgs.linuxPackages_latest;
  #boot.extraModulePackages = [ config.boot.kernelPackages.rtl8812au ];

  hardware.firmware = [ pkgs.raspberrypifw ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/2178-694E";
      fsType = "vfat";
    };

  nix.maxJobs = 2;
  nix.buildCores = 4;

  networking.hostName = "banach";

  networking.wireless.enable = true;
  networking.nameservers = [ "2001:4860:4860::8888" "2001:4860:4860::8844" ];

  # Disable docs
  services.nixosManual.enable = false;
  programs.man.enable = false;
  programs.info.enable = false;
}
