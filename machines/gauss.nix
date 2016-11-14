{ config, pkgs, ... }:

let
  theme = (import ../profiles/theme.nix {});
in
{
  imports = [
      <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
      (import ../profiles/base.nix { inherit theme; })
      ../profiles/homedir.nix
    ];

  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "virtio_blk" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  swapDevices = [ ];

  nix.maxJobs = 1;

  networking.hostName = "gauss";
  networking.hostId = "394ac2e1";
  networking.usePredictableInterfaceNames = false;

  ## Everything below is generated from nixos-in-place; modify with caution!
  boot.kernelParams = ["boot.shell_on_fail"];
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.storePath = "/nixos/nix/store";
  boot.initrd.supportedFilesystems = [ "ext4" ];
  boot.initrd.postDeviceCommands = ''
    mkdir -p /mnt-root/old-root ;
    mount -t ext4 /dev/vda1 /mnt-root/old-root ;
  '';
  fileSystems = {
    "/" = {
      device = "/old-root/nixos";
      fsType = "none";
      "options" = "bind";
    };
    "/old-root" = {
      device = "/dev/vda1";
      fsType = "ext4";
    };
  };
  
    ## Digital Ocean networking setup; manage interfaces manually
    networking.interfaces.eth0.useDHCP = false;
    networking.interfaces.eth1.useDHCP = false;

    systemd.services.setup-network = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.bash}/bin/bash -i /etc/nixos-in-place/setup-network";
      };
    };
}
