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

let
  kbd_path = "/dev/input/by-id/usb-CM_Storm_Side_print-event-kbd";
  mouse_path = "/dev/input/by-id/usb-Logitech_G500_6416B88EB90018-event-mouse";
in
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

    "hugepages=4096" # With 2MB pages, this reserves 8G of mem

    # These seem to help, but hopefully might not be necessary in the future
    "video=efifb:off"
    "amdgpu.dpm=0"

    # CPU isolation stuff
    #"isolcpus=1-3,5-7"
    "nohz_full=1-3,5-7"
    "rcu_nocbs=1-3,5-7"
  ];

  # This can be verified to be working if "Local Timer Interrupts" in /proc/interrupts is low for isolated cpus.
  boot.kernelPatches = [ {
    name = "enable-nohz-full";
    patch = "";
    extraConfig = "NO_HZ_FULL y";
  } ];

  # Force use of second AMD card
  services.xserver.deviceSection = "BusId \"2:00:0\"";

  virtualisation.libvirtd.enable = true;

  environment.systemPackages = [ pkgs.virtmanager ];

  # Add my own xml file. Use mkAfter to ensure it occurs after nixos replaces the qemu path.
  systemd.services.libvirtd.preStart = let
    win10xml = pkgs.writeText "win10.xml" (import ./win10.xml.nix { qemu=pkgs.my_qemu; kbd_path=kbd_path; mouse_path=mouse_path; });
  in lib.mkAfter ''
    mkdir -p /var/lib/libvirt/qemu
    cp ${win10xml} /var/lib/libvirt/qemu/win10.xml
  '';

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

  # By default, postgresql uses some of my huge pages! Disable this so my math is correct.
  services.postgresql.extraConfig = "huge_pages off";

  services.xserver.desktopManager.extraSessionCommands =
    let synergyConfigFile = pkgs.writeText "synergy.conf" ''
      section: screens
          bellman:
          devnull-PC:
          euler-win:
      end
      section: aliases
      end
      section: links
      bellman:
          right = devnull-PC
          down = euler-win
      devnull-PC:
          left = bellman
      euler-win:
          up = bellman
      end
    '';
    in ''
      (${pkgs.synergy}/bin/synergys -c ${synergyConfigFile}) &
    '';
}
