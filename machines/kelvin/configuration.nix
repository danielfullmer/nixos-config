{ config, lib, pkgs, ... }:

{
  imports = [
    ../../profiles/personal.nix
    ../../profiles/zerotier.nix
    ../../profiles/gaming.nix
  ];

  networking.hostName = "kelvin";

  system.stateVersion = "23.11";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true; alsa.enable = true; alsa.support32Bit = true; pulse.enable = true;
  };

  services.xserver.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

#  services.xserver.displayManager.gdm.enable = true;
#  services.xserver.displayManager.autoLogin = {
#    enable = true;
#    user = "dfullmer";
#  };

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
    yuzu
  ];

  jovian.steam = {
    enable = true;
    autoStart = true;
    user = "danielrf";
    desktopSession = "gnome";
  };
}
