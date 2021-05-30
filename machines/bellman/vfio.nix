{ config, lib, pkgs, ... }:

# See these resources:
# https://wiki.archlinux.org/index.php/PCI_passthrough_via_OVMF
# http://www.linux-kvm.org/page/Tuning_KVM
# https://www.reddit.com/r/VFIO/comments/4vqnnv/qemu_command_line_cpu_pinning/
# https://www.reddit.com/r/VFIO/comments/4ytcao/just_want_to_rant_on_my_vfio_experience/
# https://nm.reddit.com/r/VFIO/comments/5hmvlr/sharing_keyboardmouse_directly_with_spice/
# https://www.reddit.com/r/VFIO/comments/4fjsie/howto_passing_through_an_entire_block_device/
#
# https://lwn.net/Articles/656807/
# http://www.breakage.org/2013/11/15/nohz_fullgodmode/
# https://wiki.fd.io/view/VPP/How_To_Optimize_Performance_(System_Tuning)
# https://lwn.net/Articles/549592/
#
# Ensure QueryPerformanceCounter() is quick using http://www.nvidia.com/object/timer_function_performance.html
# This seems to require invtsc feature enabled
#
# Press both ctrl keys simultaneously to switch keyboard/mouse between host and guest

# Ensure MSI interrupts
# Check device manager "View -> Resources by type", "Interrupt Request (IRQ)". (PCI) 0x00.... (positive integer) devices are in line interrupt, not MSI mode.
# nvidia drivers default to off!
# Use this to enable: https://github.com/CHEF-KOCH/MSI-utility
# https://forums.guru3d.com/threads/windows-line-based-vs-message-signaled-based-interrupts.378044/
# http://vfio.blogspot.com/2014/09/vfio-interrupts-and-how-to-coax-windows.html

# https://www.reddit.com/r/VFIO/comments/ebe3l5/deprecated_isolcpus_workaround/fem8jgk/

# https://virtio-fs.gitlab.io/howto-windows.html
# sparse zfs zvols + trim, needs to be on SCSI: https://anteru.net/blog/2020/qemu-kvm-and-trim/
# https://arseniyshestakov.com/2016/03/31/how-to-pass-gpu-to-vm-and-back-without-x-restart/
# https://github.com/QaidVoid/Complete-Single-GPU-Passthrough

let
  kbd_path = "/dev/input/by-id/usb-CM_Storm_Side_print-event-kbd";
  mouse_path = "/dev/input/by-id/usb-SteelSeries_SteelSeries_Rival_3-event-mouse";
in
{
  boot.kernelParams = [
    "amd_iommu=on"
    "iommu=pt" # passthrough
    #"vfio_iommu_type1.allow_unsafe_interrupts=1"
    #"kvm.allow_unsafe_assigned_interrupts=1"
    #"kvm.ignore_msrs=1"

    # CPU isolation stuff
    #"isolcpus=1-3,5-7"
    #"nohz_full=1-3,5-7"
    #"rcu_nocbs=1-3,5-7"
  ];

  # This can be verified to be working if "Local Timer Interrupts" in /proc/interrupts is low for isolated cpus.
#  boot.kernelPatches = [ {
#    name = "vfio-config";
#    patch = "";
#    extraConfig = ''
#      NO_HZ_FULL y
#    '';
#      #PREEMPT y
#  } ];

  virtualisation.libvirtd.enable = true;

  environment.systemPackages = [ pkgs.virtmanager ];

  # Add my own xml file. Use mkAfter to ensure it occurs after nixos replaces the qemu path.
#  systemd.services.libvirtd.preStart = let
#    win10xml = pkgs.writeText "win10.xml" (import ./win10.xml.nix { qemu=pkgs.my_qemu; kbd_path=kbd_path; mouse_path=mouse_path; });
#  in lib.mkAfter ''
#    mkdir -p /var/lib/libvirt/qemu
#    cp ${win10xml} /var/lib/libvirt/qemu/win10.xml
#  '';

  # Add permission to evdev devices
  virtualisation.libvirtd.qemuVerbatimConfig = ''
    cgroup_device_acl = [
       "/dev/null", "/dev/full", "/dev/zero",
       "/dev/random", "/dev/urandom",
       "/dev/ptmx", "/dev/kvm", "/dev/kqemu",
       "/dev/rtc", "/dev/hpet", "/dev/net/tun",
       "${kbd_path}", "${mouse_path}"
    ]
  '';

  virtualisation.libvirtd.onShutdown = "shutdown";

  #networking.firewall.trustedInterfaces = [ "virbr0" ];

#  services.xserver.windowManager.i3.config = ''
#    bindsym $mod+shift+o exec ${pkgs.polkit}/bin/pkexec virsh shutdown win10
#    bindsym $mod+shift+p exec ${pkgs.polkit}/bin/pkexec virsh start win10
#  '';

  hardware.nvidia.vgpu.enable = true;
  hardware.nvidia.vgpu.unlock.enable = true;

  # Scream audio
  systemd.tmpfiles.rules = [
    "f /dev/shm/looking-glass 0660 danielrf qemu-libvirtd -"
  ];
  systemd.user.services.scream = let
    scream = pkgs.scream.override { pulseSupport = true; };
  in {
    enable = true;
    description = "Scream";
    serviceConfig = {
      ExecStart = "${scream}/bin/scream-pulse";
      Restart = "always";
    };
    partOf = [ "graphical-session.target" ];
  };
  networking.firewall.interfaces."virbr0".allowedUDPPorts = [ 4010 ]; # For Scream audio from windows VM

  # Samba + steam games
  services.samba = {
    enable = true;
    shares.steam = {
      path = "/homecache/danielrf/.local/share";
      "read only" = false;
    };
  };
  networking.firewall.interfaces.virbr0 = {
    allowedTCPPorts = [ 139 445 ];
  };

}
