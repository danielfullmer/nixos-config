{ config, lib, pkgs, ... }:

{
  imports = [
    ./bellman.nix
  ];

  boot.kernelModules = [ "vfio" "vfio_pci" "vfio_virqfd" "vfio_iommu_type1" ];

  boot.kernelParams = [
    "intel_iommu=on"
    "vfio_iommu_type1.allow_unsafe_interrupts=1"
    "kvm.allow_unsafe_assigned_interrupts=1"
    "kvm.ignore_msrs=1"
    "vfio-pci.ids=1002:67b0,1002:aac8" # Ignore AMD 390X card

    "hugepages=4096" # With 2K pages, this reserves 8G of mem

    # These seem to help, but might hopefully not be necessary in the future
    "video=efifb:off"
    "amdgpu.dpm=0" # Investigate tur
  ];

  # Force use of second AMD card
  services.xserver.deviceSection = "BusId \"2:00:0\"";
}
