{ config, lib, pkgs, ... }:

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
      ht_capab=[MAX-AMSDU-3839][SHORT-GI-20][DSSS_CCK-40]
    '';
  };

  environment.systemPackages = with pkgs; [
    raspberrypi-tools
    (v4l_utils.override { withGUI = false; })
    ffmpeg_4
  ];

  systemd.services."camera" = {
    wantedBy = [ "multi-user.target" ];
    requires = [ "network-online.target" ];
    script = ''
      ${pkgs.ffmpeg_4.bin}/bin/ffmpeg -nostats -f video4linux2 -input_format h264 -video_size 640x480 -framerate 30 -i /dev/video0 -vcodec copy -f flv "rtmp://bellman/live/ender3"
    '';
    serviceConfig = {
      DynamicUser = true;
      Group = "video";
      Restart = "always";
      RestartSec = 15;
      StartLimitInterval="1min";
      StartLimitBurst="4";
    };
  };
}
