{ config, lib, pkgs, ... }:

{
  imports = [
    ../hardware/surfacepro4.nix

    ../profiles/base.nix
    ../profiles/extended.nix
    ../profiles/yubikey.nix
    ../profiles/syncthing.nix
    ../profiles/desktop/default.nix
    ../profiles/academic.nix
    ../profiles/gdrive.nix
  ];

  theme.base16Name = "3024";

  system.nixos.stateVersion = "17.03";

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
