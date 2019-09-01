{ config, pkgs, lib, ... }:

{
  imports = [
    ../../hardware/surfacepro4.nix
  ];

  system.stateVersion = "17.03";

  boot = {
    # Use the gummiboot efi boot loader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    extraModulePackages = [ config.boot.kernelPackages.rtl8812au ]; # Just in case we need a USB wifi device
    #blacklistedKernelModules = [ "intel_ipts" ]; # Unstable for me at the moment
  };

  fileSystems."/" =
    { device = "/dev/disk/by-label/euler";
      fsType = "btrfs";
      options = [ "ssd" "discard" "compress=lzo" "autodefrag" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/508F-B0FC";
      fsType = "vfat";
    };

  swapDevices = [ ];

  nix.maxJobs = 2;
  nix.buildCores = 4;
}
