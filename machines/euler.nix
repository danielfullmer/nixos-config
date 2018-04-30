{ config, lib, pkgs, ... }:

let
  linux-surface = pkgs.fetchFromGitHub {
    owner = "jakeday";
    repo = "linux-surface";
    rev = "4.16.5-1";
    sha256 = "15cq98rfyqd4k4b6rnm7vasrcswp5ka3qryvwnf6pkhh22bhg09i";
  };

  buildFirmware = (name: subdir: src: pkgs.stdenv.mkDerivation {
    name = "${name}-firmware";
    src = src;
    nativeBuildInputs = [ pkgs.unzip ];
    sourceRoot = ".";
    installPhase = ''
      mkdir -p $out/lib/firmware/${subdir}
      cp -r * $out/lib/firmware/${subdir}
    '';
  });

  i915-firmware = buildFirmware "i915" "i915" "${linux-surface}/firmware/i915_firmware_skl.zip";

  ipts-firmware = buildFirmware "ipts" "intel/ipts" "${linux-surface}/firmware/ipts_firmware_v78.zip";

  mwifiex-firmware = buildFirmware "mwifiex" "mrvl" (pkgs.fetchFromGitHub {
    owner = "jakeday";
    repo = "mwifiex-firmware";
    rev = "5446916b53de395245d89400dea566055ec4502c";
    sha256 = "1hr6skpaiqlfvbdis8g687mh0jcpqxwcr5a3djllxgcgq7rrw9i1";
  } + /mrvl);
in
{
  imports = [
    ../profiles/base.nix
    ../profiles/extended.nix
    ../profiles/yubikey.nix
    ../profiles/syncthing.nix
    ../profiles/desktop/default.nix
    ../profiles/academic.nix
    ../profiles/gdrive.nix
  ];

  theme.base16Name = "3024";

  system.stateVersion = "17.03";

  # See https://github.com/jimdigriz/debian-mssp4 for details on surface pro 4
  # https://gitlab.com/jimdigriz/linux.git (mssp4 branch)
  # More recent: https://github.com/jakeday/linux-surface
  # https://github.com/Shadoukun/linux-surface-ipts
  boot = {
    # Use the gummiboot efi boot loader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    kernelPackages = pkgs.linuxPackages_4_16;
    kernelPatches = (map (name: { name=name; patch="${linux-surface}/patches/4.16/${name}.patch";})
      [ "acpica" "cameras" "ipts" "keyboards_and_covers" "sdcard_reader" "surfaceacpi" "surfacedock" "wifi" ]);

    initrd.kernelModules = [ "hid-multitouch" ];
    initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
    kernelModules = [ "kvm-intel" "hid-multitouch" ];
    extraModulePackages = [ config.boot.kernelPackages.rtl8812au ]; # Just in case we need a USB wifi device
    #blacklistedKernelModules = [ "intel_ipts" ]; # Unstable for me at the moment
  };

  hardware.firmware = [ pkgs.firmwareLinuxNonfree i915-firmware ipts-firmware mwifiex-firmware ];

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
    HandlePowerKey=hibernate
    HandleLidSwitch=hibernate
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

    # handle typing cover disconnects
    # https://www.reddit.com/r/SurfaceLinux/comments/6axyer/working_sp4_typecover_plug_and_play/
    ACTION=="add", SUBSYSTEM=="usb", ATTR{product}=="Surface Type Cover", RUN+="${pkgs.kmod}/bin/modprobe -r i2c_hid && ${pkgs.kmod}/modprobe i2c_hid"

    # IPTS Touchscreen (SP4)
    SUBSYSTEMS=="input", ATTRS{name}=="ipts 1B96:006A SingleTouch", ENV{ID_INPUT_TOUCHSCREEN}="1", SYMLINK+="input/touchscreen"

    # IPTS Pen (SP4)
    SUBSYSTEMS=="input", ATTRS{name}=="ipts 1B96:006A Pen", SYMLINK+="input/pen"
  '';


  # X doesn't detect the right screen size / DPI
  # 12.3in diagonal, 2734x1824 resolution
  # DisplaySize is in mm
  services.xserver.monitorSection = ''
    DisplaySize 260 173
  '';

  theme.fontSize = 8;

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

  system.autoUpgrade.enable = true;
}
