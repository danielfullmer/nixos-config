{ pkgs, lib, config, ... }:

# Example usage:
#
# {
#   imports = [ ((builtins.fetchTarball "https://github.com/danielfullmer/nixos-config/archive/master.tar.gz") + /modules/nvidia-vgpu) ];
#
#   nvidia.vgpu.enable = true;
#   nvidia.vgpu.unlock.enable = true;
# }
#
# This currently creates a merged driver from the KVM + GRID drivers for using native desktop + VM guest simultaneously.
# The merging stuff should probably be optional.

# See also: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/configuring_and_managing_virtualization/assembly_managing-nvidia-vgpu-devices_configuring-and-managing-virtualization

# I've tested on my own 1080 Ti by running:
# mdevctl start -u 2d3a3f00-633f-48d3-96f0-17466845e672 -p 0000:03:00.0 --type nvidia-51
# # nvidia-51 is the code for "GRID P40-8Q" in vgpuConfig.xml
# mdevctl define --auto --uuid 2d3a3f00-633f-48d3-96f0-17466845e672

let
  cfg = config.nvidia.vgpu;

  mdevctl = pkgs.callPackage ./mdevctl {};
  frida = pkgs.python3Packages.callPackage ./frida {};

  nvidia-vgpu-kvm-src = pkgs.runCommand "nvidia-460.32.04-vgpu-kvm-src" {
    src = pkgs.requireFile {
      name = "NVIDIA-Linux-x86_64-460.32.04-vgpu-kvm.run";
      message = "Manually NVIDIA-Linux-x86_64-460.32.04-vgpu-kvm.run to nix store, can be extracted from NVIDIA-GRID-Linux-KVM-460.32.04-460.32.03-461.33.zip";
      sha256 = "00ay1f434dbls6p0kaawzc6ziwlp9dnkg114ipg9xx8xi4360zzl";
    };
  } ''
    mkdir $out
    cd $out

    # From unpackManually() in builder.sh of nvidia-x11 from nixpkgs
    skip=$(sed 's/^skip=//; t; d' $src)
    tail -n +$skip $src | xz -d | tar xvf -
  '';

  vgpu_unlock = pkgs.stdenv.mkDerivation {
    name = "nvidia-vgpu-unlock";
    version = "unstable-2021-04-17";

    src = pkgs.fetchFromGitHub {
      owner = "DualCoder";
      repo = "vgpu_unlock";
      rev = "825e5686ac33022cf546dcb5a7e1618884317049";
      sha256 = "0n0sna6n79jbrm2sr78d34137yh8ksh5k0pmv1h8iz8vsfq2pw8i";
    };

    buildInputs = [ (pkgs.python3.withPackages (p: [ frida ])) ];

    postPatch = ''
      substituteInPlace vgpu_unlock \
        --replace /bin/bash ${pkgs.bash}/bin/bash
    '';

    installPhase = "install -Dm755 vgpu_unlock $out/bin/vgpu_unlock";
  };
in
{
  options = {
    nvidia.vgpu = {
      enable = lib.mkEnableOption "vGPU support";

      unlock.enable = lib.mkOption {
        default = false;
        type = lib.types.bool;
        description = "Unlock vGPU functionality for consumer grade GPUs";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable.overrideAttrs (
      { patches ? [], postUnpack ? "", postPatch ? "", preFixup ? "", ... }@attrs: {
      src = pkgs.requireFile {
        name = "NVIDIA-Linux-x86_64-460.32.03-grid.run";
        message = "Manually add NVIDIA-Linux-x86_64-460.32.03-grid.run to nix store, can be extracted from NVIDIA-GRID-Linux-KVM-460.32.04-460.32.03-461.33.zip";
        sha256 = "0smvmxalxv7v12m0hvd5nx16jmcc7018s8kac3ycmxam8l0k9mw9";
      };

      patches = patches ++ [
        ./nvidia-vgpu-merge.patch
      ] ++ lib.optional cfg.unlock.enable
        (pkgs.substituteAll {
          src = ./nvidia-vgpu-unlock.patch;
          vgpu_unlock = vgpu_unlock.src;
        });

      postUnpack = postUnpack + ''
        # More merging, besides patch above
        cp -r ${nvidia-vgpu-kvm-src}/init-scripts .
        cp ${nvidia-vgpu-kvm-src}/kernel/common/inc/nv-vgpu-vfio-interface.h kernel/common/inc//nv-vgpu-vfio-interface.h
        cp ${nvidia-vgpu-kvm-src}/kernel/nvidia/nv-vgpu-vfio-interface.c kernel/nvidia/nv-vgpu-vfio-interface.c
        echo "NVIDIA_SOURCES += nvidia/nv-vgpu-vfio-interface.c" >> kernel/nvidia/nvidia-sources.Kbuild
        cp -r ${nvidia-vgpu-kvm-src}/kernel/nvidia-vgpu-vfio kernel/nvidia-vgpu-vfio

        for i in libnvidia-vgpu.so.460.32.04 libnvidia-vgxcfg.so.460.32.04 nvidia-vgpu-mgr nvidia-vgpud vgpuConfig.xml sriov-manage; do
          cp ${nvidia-vgpu-kvm-src}/$i $i
        done

        chmod -R u+rw .
      '';

      postPatch = postPatch + ''
        # Move path for vgpuConfig.xml into /etc
        sed -i 's|/usr/share/nvidia/vgpu|/etc/nvidia-vgpu-xxxxx|' nvidia-vgpud

        substituteInPlace sriov-manage \
          --replace lspci ${pkgs.pciutils}/bin/lspci \
          --replace setpci ${pkgs.pciutils}/bin/setpci
      '';

      # HACK: Using preFixup instead of postInstall since nvidia-x11 builder.sh doesn't support hooks
      preFixup = preFixup + ''
        for i in libnvidia-vgpu.so.460.32.04 libnvidia-vgxcfg.so.460.32.04; do
          install -Dm755 "$i" "$out/lib/$i"
        done
        patchelf --set-rpath ${pkgs.stdenv.cc.cc.lib}/lib $out/lib/libnvidia-vgpu.so.460.32.04
        install -Dm644 vgpuConfig.xml $out/vgpuConfig.xml

        for i in nvidia-vgpud nvidia-vgpu-mgr; do
          install -Dm755 "$i" "$bin/bin/$i"
          # stdenv.cc.cc.lib is for libstdc++.so needed by nvidia-vgpud
          patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
            --set-rpath $out/lib "$bin/bin/$i"
        done
        install -Dm755 sriov-manage $bin/bin/sriov-manage
      '';
    });

    systemd.services.nvidia-vgpud = {
      description = "NVIDIA vGPU Daemon";
      wants = [ "syslog.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "forking";
        ExecStart = "${lib.optionalString cfg.unlock.enable "${vgpu_unlock}/bin/vgpu_unlock "}${lib.getBin config.hardware.nvidia.package}/bin/nvidia-vgpud";
        ExecStopPost = "${pkgs.coreutils}/bin/rm -f /var/run/nvidia-vgpud";
        Environment = [ "__RM_NO_VERSION_CHECK=1" ]; # Avoids issue with API version incompatibility when merging host/client drivers
      };
    };

    systemd.services.nvidia-vgpu-mgr = {
      description = "NVIDIA vGPU Manager Daemon";
      wants = [ "syslog.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "forking";
        KillMode = "process";
        ExecStart = "${lib.optionalString cfg.unlock.enable "${vgpu_unlock}/bin/vgpu_unlock "}${lib.getBin config.hardware.nvidia.package}/bin/nvidia-vgpu-mgr";
        ExecStopPost = "${pkgs.coreutils}/bin/rm -f /var/run/nvidia-vgpu-mgr";
        Environment = [ "__RM_NO_VERSION_CHECK=1" ];
      };
    };

    environment.etc."nvidia-vgpu-xxxxx/vgpuConfig.xml".source = config.hardware.nvidia.package + /vgpuConfig.xml;

    boot.kernelModules = [ "nvidia-vgpu-vfio" ];

    environment.systemPackages = [ mdevctl ];
    services.udev.packages = [ mdevctl ];
  };
}
