{ config, pkgs, lib, ... }:
{
  boot.kernelModules = [ "vfio" "vfio_pci" "vfio_iommu_type1" ];

  boot.kernelParams = [
    "intel_iommu=on"
    "vfio_iommu_type1.allow_unsafe_interrupts=1"
    "kvm.allow_unsafe_assigned_interrupts=1"
    "kvm.ignore_msrs=1"
    "vfio-pci.ids=1002:6798,1002:aaa0" # Ignore AMD GPUs
  ];

  environment.systemPackages = (with pkgs; [
    qemu
    win-qemu
    virtmanager
  ]);

  virtualisation.libvirtd.enable = true;

  # Only allow intel graphics driver
  boot.blacklistedKernelModules = [ "radeon" ];
  services.xserver.videoDrivers = [ "intel" ];
  services.xserver.deviceSection = "BusId \"0:02:0\"";
}
