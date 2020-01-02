{ config, pkgs, lib, ... }:

{
  imports = [
    ./configuration.nix
    ./hardware-configuration.nix
    <nixpkgs/nixos/modules/installer/cd-dvd/sd-image.nix>
  ];

  # From sd-image-raspberrypi4.nix:
  sdImage = {
    firmwareSize = 128;
    # This is a hack to avoid replicating config.txt from boot.loader.raspberryPi
    populateFirmwareCommands =
      "${config.system.build.installBootLoader} ${config.system.build.toplevel} -d ./firmware";
    # As the boot process is done entirely in the firmware partition.
    populateRootCommands = "";
  };
}
