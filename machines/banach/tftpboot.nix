# https://www.raspberrypi.org/documentation/hardware/raspberrypi/bootmodes/README.md
# https://elinux.org/RPi_U-Boot#U-Boot_script_files
# Network boot without an SD card doesn't seem to be working on my RPI3B.
# I'll just have an sdcard boot to uboot and then get its commands from
# boot.scr.img

# RPI boot notes: bootcode.bin -> config.txt -> uboot -> boot.scr.uimg on dhcp tftp host
# TODO: Make a small sd card image just booting into uboot.
# See nixos/modules/system/boot/loader/raspberrypi

# These are the paths uboot checks in order on my RPI 3
# 0A00003A.img
# pxelinux.cfg/01-b8-27-eb-9d-0f-b0
# pxelinux.cfg/0A00003A
# pxelinux.cfg/0A00003
# pxelinux.cfg/0A0000
# pxelinux.cfg/0A000
# pxelinux.cfg/0A00
# pxelinux.cfg/0A0
# pxelinux.cfg/0A
# pxelinux.cfg/0
# pxelinux.cfg/default-arm-bcm283x
# pxelinux.cfg/default-arm
# pxelinux.cfg/default

# See also profiles/pxe.nix
# nix-build ./tftpboot.nix -o /var/lib/tftpboot
let
  pkgs = import <nixpkgs> {};
  banach = import <nixpkgs/nixos> {
    configuration = { config, pkgs, lib, ... }: {
      imports = [
        ./default.nix
#        ./hardware-configuration.nix # For more easily testing just the boot
      ];

      # Ensure ethernet is available before mounting
      boot.initrd.network.enable = true;
      boot.initrd.availableKernelModules = [ "smsc95xx" ]; # For RPI3Bv1.2 networking
      boot.initrd.preLVMCommands = lib.mkOrder 200 "sleep 5"; # Hack for 19.09 to wait for network kernel module to be up before DHCP

      #boot.kernelParams = [ "boot.shell_on_fail" ];

      fileSystems."/nix/store" = {
        device = "10.0.0.1:/nix/store";
        fsType = "nfs";
        options = [ "port=2049" "nolock" "proto=tcp" ];
      };
    };
  };
  # Small modification to upstream, as uboot's pxe/extlinux support seems to do all paths relative to tftpRoot. Try to keep in sync
  extlinux-conf-builder = import ./generic-extlinux-compatible/extlinux-conf-builder.nix { inherit pkgs; };
  extlinuxFiles = pkgs.runCommand "extlinuxFiles" {} ''
    mkdir -p $out
    ${extlinux-conf-builder} -t 3 -c ${banach.config.system.build.toplevel} -d $out
  '';
in
  pkgs.runCommand "tftp-root" {} ''
    mkdir -p $out
    mkdir -p $out/pxelinux.cfg
    cp -r ${extlinuxFiles}/extlinux/extlinux.conf $out/pxelinux.cfg/01-b8-27-eb-9d-0f-b0
    cp -r ${extlinuxFiles}/nixos $out/
  ''
