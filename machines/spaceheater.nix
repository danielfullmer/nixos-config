{ config, lib, pkgs, ... }:

{
  imports = [
    ../profiles/base.nix
  ];

  system.stateVersion = "17.03";

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/disk/by-id/ata-OCZ-AGILITY4_OCZ-CS8UXT0MD692SSR2";

  boot.initrd.availableKernelModules = [ "ohci_pci" "ehci_pci" "pata_amd" "sata_nv" "firewire_ohci" "usb_storage" "usbhid" "floppy" "sd_mod" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ config.boot.kernelPackages.rtl8812au ];

  hardware.enableAllFirmware = true; # For additional wifi firmware

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/be4c48ed-6457-496a-8fdc-fcc5c2aeabc0";
      fsType = "btrfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/D569-F5D3";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/e719f318-3941-4d54-bf84-d09c4420eaec"; }
    ];

  nix.maxJobs = lib.mkDefault 2;

  networking.hostName = "spaceheater";
  networking.wireless.enable = true;
}
