# see https://github.com/jimdigriz/debian-mssp4 for details on surface pro 4
# https://gitlab.com/jimdigriz/linux.git (mssp4 branch)
# More recent: https://github.com/jakeday/linux-surface
# https://github.com/Shadoukun/linux-surface-ipts

{ config, lib, pkgs, ... }:

let
  linux-surface = pkgs.fetchFromGitHub {
    owner = "jakeday";
    repo = "linux-surface";
    rev = "4.16.7-1";
    sha256 = "04f91i6msb71yc2l7grjdf85a0dpk6nhrs740j3yi6p44zqnzswf";
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
  boot = {
    kernelPackages = pkgs.linuxPackages_4_16;
    kernelPatches = (map (name: { name=name; patch="${linux-surface}/patches/4.16/${name}.patch";})
      [ "acpica" "cameras" "ipts" "keyboards_and_covers" "sdcard_reader" "surfaceacpi" "surfacedock" "wifi" ]);

    initrd.kernelModules = [ "hid-multitouch" ];
    initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
    kernelModules = [ "kvm-intel" "hid-multitouch" ];
  };

  hardware.firmware = [ pkgs.firmwareLinuxNonfree i915-firmware ipts-firmware mwifiex-firmware ];

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
}
