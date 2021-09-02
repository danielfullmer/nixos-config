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

#  hardware.nvidia.vgpu.enable = true;
#  hardware.nvidia.vgpu.unlock.enable = true;

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
      ExecStart = "${scream}/bin/scream";
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

  # Inspired by snippets from cole-h/nixos-config
  systemd.services.libvirtd = {
    path = with pkgs; [ libvirt kmod psmisc systemd ];
    preStart = let
      # https://github.com/PassthroughPOST/VFIO-Tools/blob/0bdc0aa462c0acd8db344c44e8692ad3a281449a/libvirt_hooks/qemu
      qemuHook = pkgs.writeShellScript "qemu" ''
        #
        # Author: Sebastiaan Meijer (sebastiaan@passthroughpo.st)
        #
        # Copy this file to /etc/libvirt/hooks, make sure it's called "qemu".
        # After this file is installed, restart libvirt.
        # From now on, you can easily add per-guest qemu hooks.
        # Add your hooks in /etc/libvirt/hooks/qemu.d/vm_name/hook_name/state_name.
        # For a list of available hooks, please refer to https://www.libvirt.org/hooks.html
        #
        GUEST_NAME="$1"
        HOOK_NAME="$2"
        STATE_NAME="$3"
        MISC="''${@:4}"
        BASEDIR="$(dirname $0)"
        HOOKPATH="$BASEDIR/qemu.d/$GUEST_NAME/$HOOK_NAME/$STATE_NAME"
        set -e # If a script exits with an error, we should as well.
        # check if it's a non-empty executable file
        if [ -f "$HOOKPATH" ] && [ -s "$HOOKPATH"] && [ -x "$HOOKPATH" ]; then
            eval \"$HOOKPATH\" "$@"
        elif [ -d "$HOOKPATH" ]; then
            while read file; do
                # check for null string
                if [ ! -z "$file" ]; then
                  eval \"$file\" "$@"
                fi
            done <<< "$(find -L "$HOOKPATH" -maxdepth 1 -type f -executable -print;)"
        fi
      '';
      start = pkgs.writeShellScript "start.sh" ''
        systemctl stop display-manager.service

        /run/current-system/sw/bin/mdevctl stop -u 2d3a3f00-633f-48d3-96f0-17466845e672

        # Unbind VTconsoles
        echo 0 > /sys/class/vtconsole/vtcon0/bind
        echo 0 > /sys/class/vtconsole/vtcon1/bind

        # Unbind EFI-Framebuffer
        echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind

        systemctl stop nvidia-vgpu-mgr

        fuser -k /dev/dri/card0 /dev/nvidia*

        rmmod nvidia_uvm nvidia_drm nvidia_modeset nvidia_vgpu_vfio nvidia

        sleep 3

        modprobe vfio_pci
        virsh nodedev-detach pci_0000_03_00_0
        virsh nodedev-detach pci_0000_03_00_1
        virsh nodedev-detach pci_0000_22_00_3
      '';
      stop = pkgs.writeShellScript "stop.sh" ''
        virsh nodedev-reattach pci_0000_03_00_0
        virsh nodedev-reattach pci_0000_03_00_1
        virsh nodedev-reattach pci_0000_22_00_3

        modprobe nvidia
        modprobe nvidia_modeset
        modprobe nvidia_uvm
        modprobe nvidia_drm
        modprobe nvidia_vgpu_vfio

        # Bind VTconsoles
        echo 1 > /sys/class/vtconsole/vtcon0/bind
        echo 1 > /sys/class/vtconsole/vtcon1/bind

        # Bind EFI-Framebuffer
        echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/bind

        systemctl start nvidia-vgpud.service
        systemctl start nvidia-vgpu-mgr.service
        systemctl start display-manager.service
      '';
    in ''
      mkdir -p /var/lib/libvirt/hooks
      mkdir -p /var/lib/libvirt/hooks/qemu.d/win10-vr/prepare/begin
      mkdir -p /var/lib/libvirt/hooks/qemu.d/win10-vr/release/end

      ln -sf ${qemuHook} /var/lib/libvirt/hooks/qemu
      ln -sf ${start} /var/lib/libvirt/hooks/qemu.d/win10-vr/prepare/begin/start.sh
      ln -sf ${stop}  /var/lib/libvirt/hooks/qemu.d/win10-vr/release/end/stop.sh
    '';
  };
}
