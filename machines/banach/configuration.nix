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

  documentation.enable = false;

  # This is just on an RPI 3b (no 5ghz and AC)
  controlnet.ap = {
    enable = true;
    interface = "wlan0";
    subnetNumber = 4;
  };
  services.hostapd = {
    hwMode = "g";
    extraConfig = ''
      ieee80211n=1
      ht_capab=[SMPS-STATIC][MAX-AMSDU-3839][SHORT-GI-20][DSSS_CCK-40]
    '';
  };

  environment.systemPackages = with pkgs; [
    raspberrypi-tools
    (v4l_utils.override { withGUI = false; })
    rpi_ffmpeg
  ];

  systemd.services."camera-livingroom" = {
    wantedBy = [ "multi-user.target" ];
    requires = [ "network-online.target" ];
    script = ''
      ${rpi_ffmpeg.bin}/bin/ffmpeg -nostats -f video4linux2 -input_format h264 -video_size 640x480 -framerate 30 -i /dev/video0 -vcodec copy -f flv "rtmp://bellman/live/livingroom"
    '';
    serviceConfig = {
      DynamicUser = true;
      Group = "video";
      Restart = "always";
      RestartSec = 15;
    };
  };
}
