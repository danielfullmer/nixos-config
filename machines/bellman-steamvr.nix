{ config, lib, pkgs, ... }:

{
  imports = [
    ./bellman.nix
  ];

  ### Status as of 2017-05-27 for 390x
  # Boots correctly (needs with amdgpu.dpm=0)
  # vulkaninfo doesn't cause crash like in the past
  # Vive needs to be plugged into USB 2
  # Steam can detect the vive, but only if logging in after its plugged in--otherwise uaccess permissions are not set correctly
  # Detects basestation, controllers, headset.
  # 306 Error. No image on screen, vrcompositor log doesn't indicate anything wrong.
  # Have vrcompositor "trap divide error" in dmesg

  boot.kernelParams = [ "amdgpu.dpm=0" ];

  boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.callPackage <nixpkgs/pkgs/os-specific/linux/kernel/generic.nix> {
    inherit (pkgs) stdenv perl buildLinux;

    version = "4.11.0";
    extraMeta.branch = "4.11";

    src = pkgs.fetchgit {
      url = "git://people.freedesktop.org/~agd5f/linux";
      # branch: "amd-staging-4.9" date: 2017-04-24
      rev = "b382281b45ec359deeeeef715b182322f4fa9566";
      sha256 = "14hvirl7z9iaxg05s6yq1s4y72nbmzari6rrsgc5297k7wzn2332";
    };

    kernelPatches = with pkgs.kernelPatches; [ bridge_stp_helper modinst_arg_list_too_long ];

    features.iwlwifi = true;
    features.efiBootStub = true;
    features.needsCifsUtils = true;
    features.canDisableNetfilterConntrackHelpers = true;
    features.netfilterRPFilter = true;
  });

  ### XXX: Mesa-git stuff from github.com/corngood/nixos-mesa-git
  nixpkgs.config.packageOverrides = pkgs: with pkgs.stdenv.lib;
  let
    libdrm = pkgs.libdrm.overrideAttrs(attrs: rec {
      name = "libdrm-2.4.79";
      src = pkgs.fetchurl {
        url = "http://dri.freedesktop.org/libdrm/${name}.tar.bz2";
        sha256 = "15xiwnicf7vl1l37k8nj0z496p7ln1qp8qws7q13ikiv54cz7an6";
      };
    });

    mesa = ((pkgs.mesa_noglu.override {
      # this is probably the default by now in nixpkgs
      # without it you get opengl 2.1 contexts
      enableTextureFloats = true;
      enableRadv = true; # this isn't really needed when setting 'vulkanDrivers'
      galliumDrivers = [ "radeonsi" ];
      driDrivers = [ "radeon" ];
      vulkanDrivers = [ "radeon" ];
      llvmPackages =
        let
          rev = "300718";
          fetch = name: sha256: pkgs.fetchsvn {
            url = "http://llvm.org/svn/llvm-project/${name}/trunk/";
            inherit rev sha256;
          };
          src = fetch "llvm" "0n2ninkygczw7rgijn3ylqvz07h9rsp9i4f8pag88y2xbvbs5rki";
          compiler-rt_src = fetch "compiler-rt" "1z23sfz7pm6jjj1ymjcv67y3dfbslspd3lp7v33hmifdslnmcc4q";
        in {
          llvm = pkgs.llvmPackages_4.llvm.overrideAttrs(attrs: {
            name = "llvm-git";
            unpackPhase = ''
              unpackFile ${src}
              chmod -R u+w llvm-*
              mv llvm-* llvm
              sourceRoot=$PWD/llvm
              unpackFile ${compiler-rt_src}
              chmod -R u+w compiler-rt-*
              mv compiler-rt-* $sourceRoot/projects/compiler-rt
            '';
            # this was the quickest hack to deal with the existing postPatch
            # script deleting these files later on
            postPatch = ''
              touch test/CodeGen/AMDGPU/invalid-opencl-version-metadata1.ll
              touch test/CodeGen/AMDGPU/invalid-opencl-version-metadata2.ll
              touch test/CodeGen/AMDGPU/invalid-opencl-version-metadata3.ll
              touch test/CodeGen/AMDGPU/runtime-metadata.ll
            '' + attrs.postPatch;
        });
      };
      libdrm = libdrm;
    }).overrideAttrs(attrs: {
      name = "mesa-steamvr-git";
      src = pkgs.fetchFromGitHub {
        owner = "airlied";
        repo = "mesa";
        # branch: "radv-wip-steamvr-master" date: 2017-05-27
        rev = "bb0a048ff1f16bc138c49d98d766ff0725db3852";
        sha256 = "0glwj3q71lli336jcnwwwf6hiq8l0izskyywxsifrxqgag1bfdib";
      };
      # this nixpkg version of this patch didn't apply cleanly
      # we should probably find a less fragile way of doing this
      patches = [ ./mesa-symlink-drivers.patch ];
      nativeBuildInputs = attrs.nativeBuildInputs ++ [ pkgs.bison pkgs.flex ];
    }));

  in {
    steam = pkgs.steam.override {
      # still needed?
      newStdcpp = true;
    };
    xorg = pkgs.xorg // {
      xorgserver = pkgs.xorg.xorgserver.override {
        libdrm = libdrm;
        mesa = mesa;
      };
      xf86videoamdgpu = pkgs.xorg.xf86videoamdgpu.override {
        libdrm = libdrm;
        mesa = mesa;
      };
    };
    mesa_drivers = mesa.drivers;
  };

  hardware.opengl.s3tcSupport = true; # use patented texture compressor

  environment.systemPackages = [ pkgs.vulkan-loader ];

  services.udev.extraRules = ''
    # HTC Vive HID Sensor naming and permissioning
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0bb4", ATTRS{idProduct}=="2c87", TAG+="uaccess"
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="28de", ATTRS{idProduct}=="2101", TAG+="uaccess"
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="28de", ATTRS{idProduct}=="2000", TAG+="uaccess"
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="28de", ATTRS{idProduct}=="1043", TAG+="uaccess"
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="28de", ATTRS{idProduct}=="2050", TAG+="uaccess"
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="28de", ATTRS{idProduct}=="2011", TAG+="uaccess"
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="28de", ATTRS{idProduct}=="2012", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0bb4", ATTRS{idProduct}=="2c87", TAG+="uaccess"
    # HTC Camera USB Node
    SUBSYSTEM=="usb", ATTRS{idVendor}=="114d", ATTRS{idProduct}=="8328", TAG+="uaccess"
    # HTC Mass Storage Node
    SUBSYSTEM=="usb", ATTRS{idVendor}=="114d", ATTRS{idProduct}=="8200", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="114d", ATTRS{idProduct}=="8a12", TAG+="uaccess"
  '';
}
