{ config, lib, pkgs, ... }:

let
  rpi_ffmpeg = (pkgs.ffmpeg_4.override {
    patches = [
      ./v4l2-buffers-add-handling-for-NV21-and-YUV420P.patch
      ./v4l2-Request-selection.patch
    ];
  });
in
{
  imports = [
    ../../profiles/base.nix
  ];

  networking.hostName = "banach";

  system.stateVersion = "19.03";

  #networking.wireless.enable = true;

  documentation.enable = false;

#  services.hostapd = {
#    enable = true;
#    #interface = "wlan0";
#    ssid = "controlnet";
#    hwMode = "a"; # Just means 5ghz
#    # https://wiki.gentoo.org/wiki/Hostapd
#    extraConfig = ''
#      ieee80211n=1
#      ieee80211ac=1
#      wmm_enable=1
#    '';
#    wpaPassphrase = "verysecure";
#  };

  environment.systemPackages = with pkgs; [
    raspberrypi-tools
    (v4l_utils.override { withGUI = false; })
    rpi_ffmpeg
  ];

  nixpkgs.overlays = [ (self: super: {
    linux_rpi3 = super.linux_rpi3.overrideAttrs (attrs: {
      version = "4.19.89";
      modDirVersion = "4.19.89";
      src = pkgs.fetchFromGitHub { # Slightly newer version. TODO Remove when in nixpkgs
        owner = "raspberrypi";
        repo = "linux";
        rev = "b85f76a63d5f1b13220c61244469d55487db84f1";
        sha256 = "04pm4s2qa2pvlhf6vdb32vw4985cf76c26rqa8s9g1nbklgn5p99";
      };
    });
  }) ];

  systemd.services."camera-livingroom" = {
    wantedBy = [ "multi-user.target" ];
    requires = [ "network-online.target" ];
    script = ''
      ${rpi_ffmpeg.bin}/bin/ffmpeg -nostats -f video4linux2 -input_format h264 -video_size 640x480 -framerate 30 -i /dev/video0 -vcodec copy -f flv "rtmp://10.0.0.1/live/livingroom"
    '';
    serviceConfig = {
      DynamicUser = true;
      Group = "video";
      Restart = "always";
      RestartSec = 15;
    };
  };
}
