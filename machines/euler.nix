{ config, lib, pkgs, ... }:

{
  imports = [
    ../profiles/base.nix
    ../profiles/yubikey.nix
#    ../profiles/syncthing.nix
    ../profiles/ssmtp.nix
    ../profiles/desktop.nix
    ../profiles/academic.nix
    ../profiles/homedir.nix
  ];

  hardware.enableAllFirmware = true;
  boot.initrd.kernelModules = [ "hid-multitouch" ];
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" "hid-multitouch" ];
  boot.kernelParams = [ "i915.preliminary_hw_support=1" ]; # Remove in kernel 4.3?
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-label/euler";
      fsType = "btrfs";
      options = "ssd,discard,compress=lzo,autodefrag";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/508F-B0FC";
      fsType = "vfat";
    };

  swapDevices = [ ];

  nix.maxJobs = 4;

  # Use the gummiboot efi boot loader.
  boot.loader.gummiboot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_4_2;
  nixpkgs.config.packageOverrides = pkgs: {
    linux_4_2 = pkgs.linux_4_2.override {
      kernelPatches = [
        { patch = ../patches/linux-wily-surface.patch;
          name = "surface-pro-4";
          extraConfig = ''
            I2C_DESIGNWARE_PLATFORM m
            X86_INTEL_LPSS y
          '';
        }
      ];
    };
  };

  networking.hostName = "euler";
  networking.hostId = "56c53b14";

  networking.wireless.enable = true;

  hardware.bluetooth.enable = true;

  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "powersave";
  services.acpid.enable = true;
  services.logind.extraConfig = ''
    HandlePowerKey=suspend
    HandleLidSwitch=ignore
  '';

  services.xserver.synaptics = {
    enable = true;
    twoFingerScroll = true;
    palmDetect = true;
    buttonsMap = [ 1 3 2 ];
    fingersMap = [ 1 3 2 ];
    minSpeed = "0.8";
    maxSpeed = "1.4";
    additionalOptions = ''
    MatchDevicePath "/dev/input/event*"
    Option "vendor" "045e"
    Option "product" "07e8"
    '';
  };
  services.xserver.wacom.enable = true;
  services.xserver.multitouch.enable = true;
}
