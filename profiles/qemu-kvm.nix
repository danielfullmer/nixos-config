{ config, pkgs, lib, ... }:
{
    boot.kernelModules = [ "vfio" "vfio_pci" "vfio_iommu_type1" ];

    boot.blacklistedKernelModules = [ "radeon" ];

    boot.kernelParams = [
        "intel_iommu=on"
        "vfio_iommu_type1.allow_unsafe_interrupts=1"
        "kvm.allow_unsafe_assigned_interrupts=1"
        "kvm.ignore_msrs=1"
        #"pci-stub.ids=1002:6798,1002:aaa0"
        "vfio-pci.ids=1002:6798,1002:aaa0"
    ];

    environment.systemPackages = (with pkgs; [
        qemu
        win-qemu
    ]);

    # Only allow intel graphics driver
    services.xserver.videoDrivers = [ "intel" "modesetting" "vesa" ];
    #services.xserver.videoDrivers = [ "intel" "modesetting" "fbdev" ];
    #services.xserver.videoDrivers = [ "intel" ];
    #services.xserver.driSupport = false;
    #hardware.opengl.driSupport = false;

    services.xserver.exportConfiguration = false;
    services.xserver.displayManager.xserverArgs = [ "-verbose" "-logverbose" ];

    boot.kernelPackages = pkgs.linuxPackages_4_1;
}
