{ pkgs, lib, config, ... }:

let
  withUnlock = true;

  frida = pkgs.python3Packages.callPackage ../pkgs/frida {};

  kernel = config.boot.kernelPackages.kernel;
  kernelVersion = config.boot.kernelPackages.kernel.modDirVersion;

  nvidia-vgpu-kvm-src = pkgs.runCommand "nvidia-vgpu-kvm-460.32.04-vgpu-kvm-src" {
    src = pkgs.requireFile {
      name = "NVIDIA-Linux-x86_64-460.32.04-vgpu-kvm.run";
      message = "Extracted from NVIDIA-GRID-Linux-KVM-460.32.04-460.32.03-461.33.zip";
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

    src = pkgs.fetchFromGitHub {
      owner = "DualCoder";
      repo = "vgpu_unlock";
      rev = "cce7b5d8246fa69f59daeefa7bfb82c026a27710";
      sha256 = "0ljd1k0rlys1brswnmlv0288hana58qhzw3qip6hc594dxilpssv";
    };

    buildInputs = [ (pkgs.python3.withPackages (p: [ frida ])) ];

    installPhase = "install -Dm755 vgpu_unlock $out/bin/vgpu_unlock";
  };
in
{
  # Host driver
  systemd.services.nvidia-vgpud = {
    description = "NVIDIA vGPU Daemon";
    wants = [ "syslog.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "forking";
      ExecStart = "${lib.optionalString withUnlock "${vgpu_unlock}/bin/vgpu_unlock "}${config.hardware.nvidia.package}/bin/nvidia-vgpud";
      ExecStopPost = "${pkgs.coreutils}/bin/rm -f /var/run/nvidia-vgpud";
    };
  };

  systemd.services.nvidia-vgpu-mgr = {
    description = "NVIDIA vGPU Manager Daemon";
    wants = [ "syslog.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "forking";
      KillMode = "process";
      ExecStart = "${config.hardware.nvidia.package}/bin/nvidia-vgpu-mgr";
      ExecStopPost = "${pkgs.coreutils}/bin/rm -f /var/run/nvidia-vgpu-mgr";
    };
  };

  environment.etc."nvidia-vgpu-xxxxx/vgpuConfig.xml".source = config.hardware.nvidia.package + /vgpuConfig.xml;

  boot.kernelModules = [ "nvidia-vgpu-vfio" ];

  # Client driver
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable.overrideAttrs (
    { patches ? [], postUnpack ? "", postPatch ? "", postInstall ? "", ... }@attrs: {
    src = pkgs.requireFile {
      name = "NVIDIA-Linux-x86_64-460.32.03-grid.run";
      message = "Extracted from NVIDIA-GRID-Linux-KVM-460.32.04-460.32.03-461.33.zip";
      sha256 = "0smvmxalxv7v12m0hvd5nx16jmcc7018s8kac3ycmxam8l0k9mw9";
    };

    patches = patches ++ [
      (pkgs.substituteAll {
        src = ./nvidia-vgpu-unlock.patch;
        vgpu_unlock = vgpu_unlock.src;
      })
      ./nvidia-vgpu-merge.patch
    ];

    postUnpack = postUnpack + ''
      # More merging, besides patch above
      cp -r ${nvidia-vgpu-kvm-src}/init-scripts .
      cp ${nvidia-vgpu-kvm-src}/kernel/common/inc/nv-vgpu-vfio-interface.h kernel/common/inc//nv-vgpu-vfio-interface.h
      cp ${nvidia-vgpu-kvm-src}/kernel/nvidia/nv-vgpu-vfio-interface.c kernel/nvidia/nv-vgpu-vfio-interface.c
      echo "NVIDIA_SOURCES += nvidia/nv-vgpu-vfio-interface.c" >> kernel/nvidia/nvidia-sources.Kbuild
      cp -r ${nvidia-vgpu-kvm-src}/kernel/nvidia-vgpu-vfio kernel/nvidia-vgpu-vfio

      for i in libnvidia-vgpu.so.460.32.04 libnvidia-vgxcfg.so.460.32.04 nvidia-vgpu-mgr nvidia-vgpud vgpuConfig.xml sriov-manage; do
        cp ${nvidia-vgpu-kvm-src}/$i .
      done

      chmod -R u+rw .
    '';

    postPatch = postPatch + ''
      sed -i 's|/usr/share/nvidia/vgpu|/etc/nvidia-vgpu-xxxxx|' nvidia-vgpud
    '';

    postInstall = postInstall + ''
      for i in nvidia-modprobe nvidia-smi nvidia-vgpud nvidia-vgpu-mgr; do
        install -Dm755 "$i" "$out/bin/$i"
        patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
           --set-rpath $out/lib "$out/bin/$i"
      done

      install -Dm755 sriov-manage $out/bin/sriov-manage

      for i in libnvidia-ml.so.460.32.04 libnvidia-vgpu.so.460.32.04 libnvidia-vgxcfg.so.460.32.04; do
        install -Dm755 "$i" "$out/lib/$i"
      done

      install -Dm644 vgpuConfig.xml $out/vgpuConfig.xml
    '';
  });
}
