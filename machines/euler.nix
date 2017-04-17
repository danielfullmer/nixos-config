{ config, lib, pkgs, ... }:

{
  imports = [
    ../profiles/base.nix
    ../profiles/yubikey.nix
    ../profiles/syncthing.nix
    ../profiles/ssmtp.nix
    ../profiles/desktop/default.nix
    ../profiles/academic.nix
    ../profiles/gdrive.nix
    ../profiles/homedir.nix
  ];

  # See https://github.com/jimdigriz/debian-mssp4 for details on surface pro 4
  boot = {
    # Use the gummiboot efi boot loader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    kernelPackages = pkgs.linuxPackages_4_10;

    # These patches came from https://gitlab.com/jimdigriz/linux.git (mssp4 branch)
    kernelPatches = [
      # TODO: Patch doesn't apply against 4.10:
      # https://github.com/ipts-linux-org/ipts-linux-new/issues/3
      # { name = "IPTS";
      #   patch = ../pkgs/surface-pro-firmware/ipts.patch;
      #   extraConfig = "INTEL_IPTS m";
      # }

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
    blacklistedKernelModules = [ "intel_ipts" ]; # Unstable for me at the moment
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
  environment.etc."systemd/sleep.conf".text = ''
    [Sleep]
    SuspendState=freeze
  '';

  # Powertop suggested options
  boot.extraModprobeConfig = "options snd_hda_intel power_save=1 power_save_controller=Y";
  boot.kernel.sysctl = {
    "kernel.nmi_watchdog" = 0;
    "vm.dirty_writeback_centisecs" = 1500;
  };
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="pci", DEVPATH=="*/0000:0?:??.?", TEST=="power/control", ATTR{power/control}="auto"
    ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"
  '';

  # X doesn't detect the right screen size / DPI
  # 12.3in diagonal, 2734x1824 resolution
  # DisplaySize is in mm
  services.xserver.monitorSection = ''
    DisplaySize 260 173
  '';

  theme.fontSize = 8;

  fonts.fontconfig.dpi = 267;
  environment.variables = {
    GDK_SCALE = "2"; # Scale UI elements
    GDK_DPI_SCALE = "0.5"; # Reverse scale the fonts
  };

  services.xserver.libinput.enable = true;
  services.redshift.enable = true;

  services.synergy.client = {
    enable = true;
    screenName = "euler";
    serverAddress = "sysc-2";
  };
  # Intel VAAPI support for hardware accelerated video playback
  hardware.opengl.extraPackages = [ pkgs.vaapiIntel ];
  nixpkgs.config.mpv.vaapiSupport = true;

  environment.systemPackages = with pkgs; [ xorg.xbacklight ];
}
