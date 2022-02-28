{ config, lib, pkgs, ... }:

# See https://nixos.wiki/wiki/NixOS_on_ARM#Raspberry_Pi_3
# https://nixos.wiki/wiki/NixOS_on_ARM/Raspberry_Pi
# nix-build nixos -I nixos-config=machines/banach/sd-image.nix -A config.system.build.sdImage

{
  imports = [
    #<nixpkgs/nixos/modules/installer/cd-dvd/sd-image.nix>
  ];

  nixpkgs.localSystem = { system = "aarch64-linux"; config = "aarch64-unknown-linux-gnu"; };
  #nixpkgs.crossSystem = { system = "aarch64-linux"; config = "aarch64-unknown-linux-gnu"; };

  boot = {
    # My goal is to offload camera encoding
    # First of all, some MMAL stuff won't work on 64-bit builds and it's unlikely to ever work.
    # Apparently /dev/vcsm won't work on 64-bit ever: https://github.com/raspberrypi/linux/issues/3177
    # The newer approach seems to be to use v4l2 M2M stuff.
    # VIDEO_CODEC_BCM2835 (V4L2 M2M codec driver), does work in 64-bit
    # VIDEO_CODEC_BCM2835 gives us /dev/video{10,11,12} which let us do efficient encoding/decoding
    # But what we really want is the H264 format for /dev/video0, which is supposed to be supported in both mainline and rpi's kernel.
    # It only seems to work in mainline--and only the first time...
    # Try: v4l2-ctl --list-formats
    # ffmpeg -f video4linux2 -input_format h264 -video_size 1024x768 -framerate 30 -i /dev/video0 -vcodec copy test.mkv

    #kernelPackages = pkgs.linuxPackages_rpi3;
    kernelPackages = pkgs.linuxPackages_4_19; # 5.4 doesn't seem to work with camera

    initrd.availableKernelModules = [
      # Allows early (earlier) modesetting for the Raspberry Pi
      "vc4" "bcm2835_dma" "i2c_bcm2835"
    ];
    kernelModules = [ "bcm2835-v4l2" ]; # Camera
    #extraModulePackages = [ config.boot.kernelPackages.rtl8812au ];

    kernelParams = [ "cma=32M" "console=ttyS0,115200n8" "console=tty0" ];

    loader.grub.enable = false;
    loader.raspberryPi = {
      enable = true;
      version = 3;
      uboot.enable = true;
      # Camera config, needs to be in config.txt
      firmwareConfig = ''
        start_x=1
        gpu_mem=256
      '';
    };

    consoleLogLevel = lib.mkDefault 7;
  };


  hardware.firmware = with pkgs; [ raspberrypiWirelessFirmware raspberrypifw ];

  nix.settings.max-jobs = 2;
  nix.settings.cores = 4;

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/2178-694E";
      fsType = "vfat";
      options = [ "nofail" "noauto" ];
    };
  };
}
