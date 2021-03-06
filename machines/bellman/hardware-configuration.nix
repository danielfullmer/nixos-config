{ config, pkgs, lib, ... }:
with lib;

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

  #boot.kernelPackages = pkgs.linuxPackages_5_10;
  boot.kernelPackages = pkgs.linuxPackages_5_4;
  #boot.kernelPatches = [ { name = "OpenRGB"; patch = "${pkgs.openrgb.src}/OpenRGB.patch"; } ];
  boot.kernelModules = [
    "kvm-amd"
    "it87" # For sensors on gigabyte motherboard
    "i2c-dev" "i2c-piix4" # Ensure we can access i2c bus for RGB memory
  ];
  #boot.extraModulePackages = [ config.boot.kernelPackages.rtl8812au ];
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
    "/homecache" = { device = "pool/homecache"; fsType = "zfs"; };
    "/nix" = { device = "pool/nix"; fsType = "zfs"; };
    #"/tmp" = { device = "pool/tmp"; fsType = "zfs"; };
    "/mnt/backup" = { device = "tank/backup"; fsType = "zfs"; options = [ "nofail" ]; };
    "/mnt/cache" = { device = "tank/cache"; fsType = "zfs"; options = [ "nofail" ]; };

    "/boot" = {
      device = "/dev/disk/by-uuid/3AF1-2802";
      fsType = "vfat";
    };
  };
  sops.secrets."zfs-key" = {
    format = "binary";
    sopsFile = ./secrets/zfs.key;
  };
  boot.initrd.secrets."/zfs.key" = config.sops.secrets.zfs-key.path;
  boot.initrd.postDeviceCommands = mkAfter ''
    zfs load-key pool/root < /zfs.key
    zfs load-key pool/home < /zfs.key
    zfs load-key pool/win10 < /zfs.key
  '';

  services.sanoid = let
    common = {
      hourly = 48;
      daily = 30;
      monthly = 6;
      yearly = 0;
    };
  in {
    enable = true;
    extraArgs = [ "--verbose" ];
    datasets."pool/home" = common;
    datasets."pool/root" = common;
    datasets."pool/win10" = common;
    datasets."tank/backup" = common;
  };

  services.syncoid = {
    enable = true;
    commands = let
      common = {
        sshKey = config.sops.secrets.wrench-zfs-syncoid-ssh.path;
        sendOptions = "w"; # send raw for encrypted volume
        extraArgs = [ "--no-sync-snap" ]; # Don't create any snapshots, just send them
      };
    in {
      "pool/home" = { target = "zfs-syncoid@wrench:wrenchpool/bellman/home"; } // common;
      "pool/root" = { target = "zfs-syncoid@wrench:wrenchpool/bellman/root"; } // common;
      "pool/win10" = { target = "zfs-syncoid@wrench:wrenchpool/bellman/win10"; } // common;
      "tank/backup" = { target = "zfs-syncoid@wrench:wrenchpool/bellman/backup"; } // common;
    };
  };
  sops.secrets.wrench-zfs-syncoid-ssh = {
    owner = config.services.syncoid.user;
  };
  systemd.services.syncoid.serviceConfig.SupplementaryGroups = [ config.users.groups.keys.name ];

  swapDevices = [ ];

  nix.maxJobs = 4;
  nix.buildCores = 64;

  # Currently have 96GB of RAM.
  zramSwap.enable = true;
  zramSwap.memoryPercent = 150;
  #boot.tmpOnTmpfs = true;
  # Since tmpOnTmpfs defaults to only 50% memory usage:
  systemd.mounts = [
    {
      what = "tmpfs";
      where = "/tmp";
      type = "tmpfs";
      mountConfig.Options = [ "mode=1777" "strictatime" "rw" "nosuid" "nodev" "size=150G" ]; # 120G is more ram than we have, would need zram compression to fill up.
    }
  ];

  environment.systemPackages = with pkgs; [
    lm_sensors
    krakenx # For NZXT X62 AIO cooler
    #openrgb # For RGB lights
    rivalcfg # For Steelseries Rival 3 mouse
  ];

  #services.udev.packages = with pkgs; [ rivalcfg ]; # Current udev rules are too permissive


  powerManagement.cpuFreqGovernor = "conservative"; # Let's save some temperature and electricity

  # For Seiki 4K monitor
  fonts.fontconfig.dpi = 115;
  fonts.fontconfig.subpixel.rgba = "bgr";
  theme.fontSize = 12;
#  services.xserver.monitorSection = ''
#    DisplaySize 698 393
#  '';


  # Nvidia 1080ti
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.modesetting.enable = true;
  hardware.opengl.extraPackages = with pkgs; [ vaapiVdpau ];
  services.xserver.screenSection = ''
    Option         "Stereo" "0"
    Option         "nvidiaXineramaInfoOrder" "DFP-1"
    Option         "metamodes" "HDMI-0: nvidia-auto-select +2560+840, DP-0: nvidia-auto-select +6400+0 {rotation=right}, DVI-D-0: nvidia-auto-select +0+1200"
    Option         "SLI" "Off"
    Option         "MultiGPU" "Off"
    Option         "BaseMosaic" "off"
    Option         "AllowIndirectGLXProtocol" "off"
    Option         "TripleBuffer" "on"
  '';
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

  hardware.firmware = [ pkgs.wireless-regdb ];
  hardware.enableRedistributableFirmware = true;
  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom="US"
  '';

  services.xserver.windowManager.i3.status = {
    config = ''
      cpu_temperature 0 {
              max_threshold = 85
              path = "/sys/devices/pci0000:00/0000:00:18.3/hwmon/hwmon*/temp1_input"
      }
    '';
    order = mkBefore [ "cpu_temperature 0" ];
  };

  hardware.bluetooth.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;
  hardware.pulseaudio.zeroconf.discovery.enable = true;

  services.apcupsd.enable = true;
}
