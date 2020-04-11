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
  services.hostapd = {
    enable = true;
    interface = "wlan0";
    ssid = "controlnet_nomap";
    hwMode = "g";
    # https://wiki.gentoo.org/wiki/Hostapd
    extraConfig = ''
      ieee80211n=1
      require_ht=1
      ht_capab=[MAX-AMSDU-3839][HT40][SHORT-GI-20][DSSS_CCK-40]
      rsn_pairwise=CCMP
    '';
    wpaPassphrase = "verysecure";
  };

  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;
    servers = [ "8.8.8.8" "8.8.4.4" ];
    extraConfig = ''
      interface=wlan0

      dhcp-range=192.168.3.2,192.168.3.254
    '';
  };

  networking.interfaces.wlan0.ipv4.addresses = [ { address = "192.168.3.1"; prefixLength = 24; }];
  networking.firewall.trustedInterfaces = [ "wlan0" ];
  networking.nat.enable = true;
  networking.nat.internalInterfaces = [ "wlan0" ];

  environment.systemPackages = with pkgs; [
    wirelesstools iw
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
