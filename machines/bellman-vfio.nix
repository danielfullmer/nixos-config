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

  # TODO: Use a cpuset instead of isolcpu.
  # See https://access.redhat.com/solutions/1445073
  # Make a script to enable exclusive CPU access for qemu--so it can be enabled/disabled at will.

  # Force use of second AMD card
  services.xserver.deviceSection = "BusId \"2:00:0\"";

  environment.systemPackages = with pkgs; [ my_qemu ];

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
  # Press both ctrl keys simultaneously to switch keyboard/mouse between host and guest
  systemd.services.qemu-windows = {
    wantedBy = [ "multi-user.target" ];

    script = ''
      vfiobind() {
          dev="$1"
          vendor=$(cat /sys/bus/pci/devices/$dev/vendor)
          device=$(cat /sys/bus/pci/devices/$dev/device)
          if [ -e /sys/bus/pci/devices/$dev/driver ]; then
              echo $dev > /sys/bus/pci/devices/$dev/driver/unbind
          fi
          echo $vendor $device > /sys/bus/pci/drivers/vfio-pci/new_id
      }

      vfiobind 0000:01:00.0 # 390x
      vfiobind 0000:01:00.1
      #vfiobind 0000:00:14.0 # USB 3 controller
      vfiobind 0000:06:00.0 # USB 3 controller

      export QEMU_AUDIO_DRV=pa
      export QEMU_PA_SERVER=/run/user/1000/pulse/native

      ${pkgs.my_qemu}/bin/qemu-system-x86_64 \
        -name win10 \
        -enable-kvm \
        -rtc base=localtime \
        -m 8G \
        -mem-path /dev/hugepages \
        -mem-prealloc \
        -cpu host,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time \
        -smp sockets=1,cores=6,threads=1 \
        -vcpu vcpunum=0,affinity=1 \
        -vcpu vcpunum=1,affinity=2 \
        -vcpu vcpunum=2,affinity=3 \
        -vcpu vcpunum=3,affinity=5 \
        -vcpu vcpunum=4,affinity=6 \
        -vcpu vcpunum=5,affinity=7 \
        -device vfio-pci,host=01:00.0,multifunction=on \
        -device vfio-pci,host=01:00.1 \
        -drive file=/dev/disk/by-id/ata-Samsung_SSD_850_EVO_500GB_S21HNXAG469669M,if=none,format=raw,aio=native,cache=none,id=hd0 \
        -device virtio-scsi-pci,id=scsi -device scsi-block,drive=hd0,bus=scsi.0 \
        -nographic \
        -monitor unix:/run/qemu-windows.socket,server,nowait \
        -net nic,model=virtio \
        -net user \
        -device vfio-pci,host=06:00.0 \
        -object input-linux,id=kbd,evdev=/dev/input/by-id/usb-CM_Storm_Side_print-event-kbd,grab_all=yes \
        -object input-linux,id=mouse,evdev=/dev/input/by-id/usb-Logitech_G500_6416B88EB90018-event-mouse
    '';

    preStop = ''
      echo system_powerdown | ${pkgs.socat}/bin/socat - UNIX-CONNECT:/run/qemu-windows.socket
    '';

    serviceConfig = {
      # Don't actually kill with SIGTERM as by default, since we want to shut down gracefully using the above preStop.
      # Instead, send an ignored signal to the qemu process.
      # This is better than using KillMode=none, since this will still wait for the process to stop.
      KillMode = "mixed";
      KillSignal = "WINCH";

      # Use FIFO scheduling. Since the VM threads have affinity for the first 3 cores,
      # we should always have at least one available for the rest of the overall linux system.
      # I normally wouldn't worry about this, but the HTC Vive can't handle delays from the underlying system and still hit framerate.
      CPUSchedulingPolicy = "fifo";
      CPUSchedulingPriority = "50";
    };
  };

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
