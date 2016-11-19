{ config, lib, pkgs, ... }:

let
  theme = (import ../profiles/theme.nix {});
in
{
  imports = [
    (import ../profiles/base.nix { inherit theme; })
    ../profiles/yubikey.nix
    ../profiles/syncthing.nix
    ../profiles/ssmtp.nix
    (import ../profiles/desktop.nix { inherit theme; })
    ../profiles/autologin.nix
    ../profiles/academic.nix
    ../profiles/homedir.nix
  ];

  hardware.enableAllFirmware = true;
  boot.initrd.kernelModules = [ "hid-multitouch" ];
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" "hid-multitouch" ];
  boot.kernelParams = [
    "i915.preliminary_hw_support=1" # Remove in kernel 4.3?
    "i915.enable_guc_submission=Y"
    "i915.guc_log_level=3"
  ];
  boot.blacklistedKernelModules = [ "mei_itouch_hid" ]; # Blacklist since it often crashes
  boot.extraModulePackages = [ ];

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

  # Use the gummiboot efi boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.callPackage <nixpkgs/pkgs/os-specific/linux/kernel/generic.nix> {
      inherit (pkgs) stdenv perl buildLinux;

      version = "4.6.7";
      extraMeta.branch = "4.6";

      src = pkgs.fetchFromGitHub {
        owner = "npjohnson";
        repo = "linux-surface";
        # branch: "linux-4.6.y"
        rev = "e7eaca4b8ddeeabcb307017838918f34c7ceecaa";
        sha256 = "0zq87ipj5xj74nvph1qgh7z0yrc69sw3hb84ailw03q91kc87sy1";
      };

      # From README-IPTS.md of the repo above
      extraConfig = "INTEL_MEI_ITOUCH m";

      kernelPatches = [];

      features.iwlwifi = true;
      features.efiBootStub = true;
      features.needsCifsUtils = true;
      features.canDisableNetfilterConntrackHelpers = true;
      features.netfilterRPFilter = true;
   });

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

  environment.variables = {
    GDK_SCALE = "2"; # Scale UI elements
    GDK_DPI_SCALE = "0.5"; # Reverse scale the fonts
  };

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

  services.synergy.client = {
    enable = true;
    screenName = "euler";
    serverAddress = "sysc-2";
  };
}
