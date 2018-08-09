{ config, lib, pkgs, ... }:

# nix-build nixos -I nixos-config=machines/banach.nix -A config.system.build.sdImage
# See https://nixos.wiki/wiki/NixOS_on_ARM#Raspberry_Pi_3

let
  extlinux-conf-builder =
    import <nixpkgs/nixos/modules/system/boot/loader/generic-extlinux-compatible/extlinux-conf-builder.nix> {
      inherit pkgs;
    };
in
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/sd-image.nix>
    ../profiles/base.nix
    ../profiles/gdrive.nix
  ];

  theme.base16Name = "isotope";

  system.stateVersion = "18.03";

  #nixpkgs.localSystem = { system = "aarch64-linux"; } // (import <nixpkgs/lib>).systems.examples.aarch64-multiplatform;
  nixpkgs.localSystem = { system = "aarch64-linux"; config = "aarch64-unknown-linux-gnu"; }; # The above one should work but doesn't

  # XXX: Parts of this taken from nixos/modules/installer/cd-dvd/sd-image-aarch64.nix. Try to keep it in sync.
  # Bootloader was initially created from that SD image
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  boot.initrd.availableKernelModules = [ "usbhid" ];
  boot.kernelModules = [ ];
  boot.kernelParams = [
    "cma=32M" # More memory for graphics
    "console=ttyS0,115200n8" # Serial output on GPIO pins
    "console=ttyS1,115200n8" # Mine seems to end up on ttyS1 for some reason...
    "console=ttyAMA0,115200n8" # Bluetooth
    "console=tty0" # HDMI output
  ];
  systemd.services."serial-getty@ttyS1".enable = true;
  #boot.consoleLogLevel = 7;
  boot.kernelPackages = pkgs.linuxPackages_latest; # RPI3 uses latest kernel
  #boot.extraModulePackages = [ config.boot.kernelPackages.rtl8812au ];

  sdImage = {
    populateBootCommands = let
      configTxt = pkgs.writeText "config.txt" ''
        kernel=u-boot-rpi3.bin

        # Boot in 64-bit mode.
        arm_control=0x200

        # U-Boot used to need this to work, regardless of whether UART is actually used or not.
        # TODO: check when/if this can be removed.
        enable_uart=1

        # XXX: My modification
        # UART is software controlled and this makes it stable. May affect other stuff I don't know about though.
        core_freq=250

        # Prevent the firmware from smashing the framebuffer setup done by the mainline kernel
        # when attempting to show low-voltage or overtemperature warnings.
        avoid_warnings=1
      '';
      in ''
        (cd ${pkgs.raspberrypifw}/share/raspberrypi/boot && cp bootcode.bin fixup*.dat start*.elf $NIX_BUILD_TOP/boot/)
        cp ${pkgs.ubootRaspberryPi3_64bit}/u-boot.bin boot/u-boot-rpi3.bin
        cp ${configTxt} boot/config.txt
        ${extlinux-conf-builder} -t 3 -c ${config.system.build.toplevel} -d ./boot
      '';
  };

  hardware.firmware = with pkgs; [ raspberrypi-wireless ];

  nix.maxJobs = 2;
  nix.buildCores = 4;

  networking.hostName = "banach";

  networking.wireless.enable = true;
  networking.nameservers = [ "2001:4860:4860::8888" "2001:4860:4860::8844" ];

  # Disable docs
  services.nixosManual.enable = false;
  documentation.man.enable = false;
  documentation.info.enable = false;
}
