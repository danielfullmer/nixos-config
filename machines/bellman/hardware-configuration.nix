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
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.memtest86.enable = true;
  boot.loader.systemd-boot.consoleMode = "auto";
  boot.loader.efi.canTouchEfiVariables = true;

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
  boot.initrd.postResumeCommands = mkAfter ''
    zfs load-key pool/root < /zfs.key
    zfs load-key pool/home < /zfs.key
  '';

  services.sanoid = let
    common = {
      hourly = 48;
      daily = 30;
      monthly = 12;
      yearly = 1;
    };
  in {
    enable = true;
    extraArgs = [ "--verbose" ];
    datasets."pool/home" = common;
    datasets."pool/root" = common;
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
      "tank/backup" = { target = "zfs-syncoid@wrench:wrenchpool/bellman/backup"; } // common;
    };
    service.serviceConfig.SupplementaryGroups = [ config.users.groups.keys.name ];
  };
  sops.secrets.wrench-zfs-syncoid-ssh = {
    owner = config.services.syncoid.user;
  };

  swapDevices = [ ];

  nix.settings.max-jobs = 16;
  nix.settings.cores = 64;
  #nix.systemFeatures = [ "x86_64-linux:kvm" "nixos-test" "benchmark" "big-parallel" ];

  # Currently have 96GB of RAM.
  zramSwap.enable = true;
  zramSwap.memoryPercent = 200;
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

  services.udev.packages = with pkgs; [
    #openrgb
    #rivalcfg # Current udev rules are too permissive
  ];

  powerManagement.cpuFreqGovernor = "conservative"; # Let's save some temperature and electricity
  powerManagement.powertop.enable = true;

  # For LG 55inch C1 OLED TV
  services.xserver.dpi = 120; # Not accurate, but used to get good scaling at viewing distance. True value is more like 80 dpi
  #theme.fontSize = 12;
#  services.xserver.monitorSection = ''
#    DisplaySize 698 393
#  '';


  # Nvidia 1080ti
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = false; # The onen driver only works on Turing (2xxx) and later cards
  hardware.nvidia.modesetting.enable = true;
  hardware.opengl.extraPackages = with pkgs; [ vaapiVdpau ];
  services.xserver.screenSection = ''
    Option         "Stereo" "0"
    #Option         "metamodes" "DP-0: 4k117hz_rb +0+650 {ForceCompositionPipeline=On}, DP-4: nvidia-auto-select +3840+0 {rotation=right, ForceCompositionPipeline=On}"

    Option          "ModeValidation" "AllowNonEdidModes, NoHorizSyncCheck, NoVertRefreshCheck"

    Option         "SLI" "Off"
    Option         "MultiGPU" "Off"
    Option         "BaseMosaic" "off"
    Option         "AllowIndirectGLXProtocol" "off"
    Option         "TripleBuffer" "on"
    Option     "RegistryDwords"  "RMUseSwI2c=0x01; RMI2cSpeed=100"
  '';
  # NVIDIA 1080ti (Pascal) does not support Display Stream Compression (DSC).
  # So we have to use a custom modeline to have it fit into DisplayPort HBR3
  # https://tomverbeure.github.io/video_timings_calculator
  # CVT-RBv2 (reduced blanking) timings don't seem to work, but CVT-RB does.
  # 117Hz is the fastest CVT-RB can do while still staying below the bandwidth limit of HBR3
  #
  # To manually switch into this mode, use: xrandr --output DP-0 --mode "3840x2160" -r 116.98
  #
  # See also: https://www.reddit.com/r/OLED_Gaming/comments/mbpiwy/lg_oled_gamingpc_monitor_recommended_settings/
#  services.xserver.monitorSection = ''
#    Modeline "4k117hz_rb" 1068.25 3840 3888 3920 4000 2160 2163 2168 2283 +HSync -VSync
#  '';
  #hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.production; # v515.x works with my custom modeline, but 520.56 didn't...
  #services.xserver.displayManager.xserverArgs = [ "-logverbose 7" ];

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

  #hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;

  # EDID file made by adding 110hz mode using CRU.exe
  boot.kernelParams = [ "drm.edid_firmware=DP-3:edid_110.bin" ];

  hardware.firmware = [
    pkgs.wireless-regdb
    (pkgs.runCommand "custom-edid" {} ''
      mkdir -p $out/lib/firmware
      cp ${./edid_110.bin} $out/lib/firmware/edid_110.bin
    '')
  ];
  hardware.enableRedistributableFirmware = true;
  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom="US"
    options nvidia NVreg_RegistryDwords=RMUseSwI2c=0x01;RMI2cSpeed=100
  '';
  # nvidia options are for DDC/CI support

  services.xserver.windowManager.i3.status = {
    config = ''
      cpu_temperature 0 {
              max_threshold = 85
              path = "/sys/devices/pci0000:00/0000:00:18.3/hwmon/hwmon*/temp1_input"
      }
    '';
    order = mkBefore [ "cpu_temperature 0" ];
  };

  hardware.pulseaudio.package = pkgs.pulseaudioFull;
  hardware.pulseaudio.zeroconf.discovery.enable = true;
  hardware.pulseaudio.daemon.config = {
    default-sample-channels = 6; # 5.1 surround: https://help.ubuntu.com/community/SurroundSound
  };

  services.apcupsd.enable = true;
}
