{ config, pkgs, lib, ... }:

let
  externalIP = "167.71.187.97";
in
{
  imports = [
    <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
  ];

  system.stateVersion = "19.03";

  # Stuff from nixos-infect below:
  boot.loader.grub.device = "/dev/vda";
  fileSystems."/" = { device = "/dev/vda1"; fsType = "ext4"; };

  networking.defaultGateway = "167.71.176.1";
  networking.defaultGateway6 = "2604:a880:800:c1::1";
  networking.dhcpcd.enable = false;
  networking.usePredictableInterfaceNames = lib.mkForce true;
  networking.interfaces = {
    ens3 = {
      ipv4.addresses = [
        { address=externalIP; prefixLength=20; }
        { address="10.17.0.5"; prefixLength=16; }
      ];
      ipv6.addresses = [
        { address="2604:a880:800:c1::3b8:4001"; prefixLength=64; }
      ];
    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="be:4e:ee:18:60:e8", NAME="ens3"
  '';
}
