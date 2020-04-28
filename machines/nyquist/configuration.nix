{ config, pkgs, ... }:

{
  imports = [
    ../../profiles/base.nix
    ../../profiles/interactive.nix
    ../../profiles/extended.nix
    ../../profiles/kdeconnect.nix
    ../../profiles/yubikey.nix
    ../../profiles/desktop/default.nix
    ../../profiles/academic.nix
    ../../profiles/gdrive.nix
    ../../profiles/tor.nix
  ];

  networking.hostName = "nyquist";
  networking.hostId = "d8ab690e";

  services.plex.enable = true;
  systemd.services.plex.requires = [ "gdrive2-enc.service" ];
  #networking.firewall.allowedTCPPorts = [ 32400 ];

  environment.systemPackages = with pkgs; [ keyboard-firmware ];

  system.autoUpgrade.enable = true;

  programs.adb.enable = true;
  users.users.danielrf.extraGroups = [ "adbusers" ];

#  services.zoneminder = {
#    enable = true;
#    database = {
#      createLocally = true;
#      username = "zoneminder";
#    };
#    hostname = "zoneminder.daniel.fullmer.me";
#  };

  systemd.services."camera-office" = {
    wantedBy = [ "multi-user.target" ];
    requires = [ "network-online.target" ];
    # require nginx?
    script = ''
      ${pkgs.ffmpeg_4.bin}/bin/ffmpeg -nostats -f video4linux2 -input_format mjpeg -video_size 640x480 -framerate 10 -i /dev/video0 -vcodec copy -f mjpeg "tcp://0.0.0.0:9000?listen"
    '';
    serviceConfig = {
      DynamicUser = true;
      Group = "video";
      Restart = "always";
      RestartSec = 15;
    };
  };
}
