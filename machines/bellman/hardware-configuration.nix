{ config, pkgs, lib, ... }:

# AMD Ryzen Threadripper 3970X
# 4x16GB G.Skill Trident Z Neo Series PC4-28800 DDR4 3600MHz CL16-19-19-39 1.35V F4-3600C16D-32GTZNC
# GIGABYTE TRX40 AORUS Master
# NZXT Kraken X62 280mm - RL-KRX62-02 (2x140mm AIO cooler)
# EVGA GeForce 1080 Ti SC2 Hybrid 11G (120mm AIO cooler)
# 3x1Tb Sabrent Rocket NVMe 4.0 Gen4 PCIe M.2 (SB-ROCKET-NVMe4-1TB)
# EVGA 750 GQ 210-GQ-0750-V1 80+ GOLD 750W PSU
# LIAN LI PC-O11 Dynamic Black Case
{
  system.stateVersion = "18.03";

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.memtest86.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [
    "kvm-amd"
    "it87" # For sensors on gigabyte motherboard
  ];
  boot.extraModulePackages = [ config.boot.kernelPackages.rtl8812au ];
  hardware.firmware = [ pkgs.firmwareLinuxNonfree ];  # For any other wifi firmware
  hardware.cpu.amd.updateMicrocode = true;

  boot.initrd.availableKernelModules = [
    "xhci_pci" "ehci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"
    "nvme" "nvme_core"
  ];

  # Current partition status:
  # One zfs with mirrored 2x 2Tb HDDs, backed with 1x 500GB SSD
  # Seagate 2TB ST2000DM006 has 4096 size blocks: ashift=12
  # Samsung SSD 850/860 EVO 500G have 8192 size blocks: ashift=13
  # However, vdevs can't be removed from a pool if they have different ashift values, so just use ashift=12 everywhere.
  boot.supportedFilesystems = [ "zfs" ];
  boot.initrd.supportedFilesystems = [ "zfs" ];
  boot.zfs.enableUnstable = true;
  services.zfs.autoScrub.enable = true;

  fileSystems = {
    "/" = { device = "pool/root"; fsType = "zfs"; };
    "/home" = { device = "pool/home"; fsType = "zfs"; };
    "/nix" = { device = "pool/nix"; fsType = "zfs"; };
    "/tmp" = { device = "pool/tmp"; fsType = "zfs"; };

    "/boot" = {
      device = "/dev/disk/by-uuid/3AF1-2802";
      fsType = "vfat";
    };
  };

  swapDevices = [ ];

  nix.maxJobs = 4;
  nix.buildCores = 64;

  zramSwap.enable = true;
  #boot.tmpOnTmpfs = true; # XXX: Building big programs doesn't work so hot with this.

  environment.systemPackages = with pkgs; [
    lm_sensors
    krakenx # For NZXT X62 AIO cooler
    openrgb # For RGB lights
  ];

  powerManagement.cpuFreqGovernor = "ondemand"; # Let's save some temperature and electricity

  # For Seiki 4K monitor
  fonts.fontconfig.dpi = 115;
  fonts.fontconfig.subpixel.rgba = "bgr";
  theme.fontSize = 12;
#  services.xserver.monitorSection = ''
#    DisplaySize 698 393
#  '';

#  services.xserver.xrandrHeads = [
#    { output = "DP-0"; primary = true; }
#    { output = "DP-4"; }
#    { output = "DP-5"; }
#    { output = "DVI-D-0";
#      monitorConfig = ''
#        Option "Rotate" "Left"
#      '';
#    }
#  ];
  services.xserver.screenSection = ''
    Option         "Stereo" "0"
    Option         "nvidiaXineramaInfoOrder" "DFP-4"
    Option         "metamodes" "DVI-D-0: nvidia-auto-select +5760+0 {rotation=left}, HDMI-0: nvidia-auto-select +0+1480, DP-2: 1920x2160 +1920+132, DP-4: 1920x2160 +3840+132"
    Option         "SLI" "Off"
    Option         "MultiGPU" "Off"
    Option         "BaseMosaic" "off"
    Option         "AllowIndirectGLXProtocol" "off"
    Option         "TripleBuffer" "on"
  '';

  # Nvidia 1080ti
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.extraPackages = with pkgs; [ vaapiVdpau ];
}
