{ config, lib, pkgs, ... }:

{
  imports = [
    (import ../profiles/base.nix {})
    ../profiles/yubikey.nix
    ../profiles/syncthing.nix
    ../profiles/ssmtp.nix
    (import ../profiles/desktop {})
    ../profiles/autologin.nix
    ../profiles/academic.nix
    ../profiles/homedir.nix
  ];

  # See https://github.com/jimdigriz/debian-mssp4 for details on surface pro 4
  boot = {
    # Use the gummiboot efi boot loader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    kernelPackages = pkgs.linuxPackages_testing;

    # These patches came from https://gitlab.com/jimdigriz/linux.git (mssp4 branch)
    kernelPatches = [
      { name = "IPTS";
        patch = ../pkgs/surface-pro-firmware/ipts.patch;
        extraConfig = "INTEL_IPTS m";
      }
      # This patch should be in 4.10
      { name = "type-cover";
        patch = ../pkgs/surface-pro-firmware/type-cover.patch;
      }
      # See https://bugzilla.kernel.org/show_bug.cgi?id=188351
      { name = "mwifiex-panic-fix";
        patch = ../pkgs/surface-pro-firmware/mwifiex-panic-fix.patch;
      }
    ];

    initrd.kernelModules = [ "hid-multitouch" ];
    initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
    kernelModules = [ "kvm-intel" "hid-multitouch" ];
    kernelParams = [
      #"resume=/dev/mapper/lvm--quatermain-swap"
      "noresume"
    ];
    extraModulePackages = [ ];
  };

  hardware = {
    enableAllFirmware = true;
    firmware = [ pkgs.surface-pro-firmware ];
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

  networking.hostName = "euler";
  networking.hostId = "56c53b14";

  #networking.wireless.enable = true;
  networking.networkmanager.enable = true;

  hardware.bluetooth.enable = true;

  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "powersave";
  services.acpid.enable = true;
  services.logind.extraConfig = ''
    HandlePowerKey=suspend
    HandleLidSwitch=suspend
  '';

  # X doesn't detect the right screen size / DPI
  # 12.3in diagonal, 2734x1824 resolution
  # DisplaySize is in mm
  services.xserver.monitorSection = ''
    DisplaySize 260 173
  '';

  fonts.fontconfig.dpi = 267;
  environment.variables = {
    GDK_SCALE = "2"; # Scale UI elements
    GDK_DPI_SCALE = "0.5"; # Reverse scale the fonts
  };

  services.xserver.libinput.enable = true;

  services.synergy.client = {
    enable = true;
    screenName = "euler";
    serverAddress = "sysc-2";
  };
}
