{ config, lib, pkgs, modulesPath, ... }:

{
  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "laplace/root";
      fsType = "zfs";
    };

  fileSystems."/home" =
    { device = "laplace/home";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    { device = "laplace/nix";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/24B7-6F87";
      fsType = "vfat";
    };

  swapDevices = [ ];

  hardware.enableRedistributableFirmware = true;
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.video.hidpi.enable = lib.mkDefault true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.xserver.windowManager.i3.status = {
    config = ''
      battery 1 {
              format = "%status %percentage %remaining %emptytime"
              format_down = "No battery"
              status_chr = "⚡ CHR"
              status_bat = "🔋 BAT"
              status_full = "☻ FULL"
              path = "/sys/class/power_supply/BAT%d/uevent"
              low_threshold = 10
      }

      cpu_temperature 0 {
              max_threshold = 85
              path = "/sys/devices/platform/coretemp.0/hwmon/hwmon*/temp1_input"
      }
    '';
    order = lib.mkBefore [ "battery 1" "cpu_temperature 0" ];
  };
}
