{ config, pkgs, lib, ... }:

{
  # Stuff for streaming cameras?
  # Currently unencrypted. Maybe fix in the future?
  # https://github.com/arut/nginx-rtmp-module/wiki/Directives#hls
  # TODO: Need to mkdir and chown in startup
  # Can watch rtmp without latency of HLS using e.g. mpv --no-buffer "rtmp://bellman/live/ender3"
  services.nginx.appendConfig = ''
    rtmp {
      server {
        listen 1935;
        chunk_size 4096;

        application live {
          live on;
          record off;
          hls on;
          hls_path /dev/shm/hls;
          hls_fragment 2s;
          hls_playlist_length 10s;
        }
      }
    }
  '';
  services.nginx.virtualHosts."daniel.fullmer.me" = {
    locations."/cameras".public = false;
    locations."/cameras/hls/" = {
      alias = "/dev/shm/hls/";
      extraConfig = ''
        types {
          application/vnd.apple.mpegurl m3u8;
          video/mp2t ts;
        }
        add_header Cache-Control no-cache;
      '';
      public = false;
    };
  };

#  services.zoneminder = {
#    enable = true;
#    database = {
#      createLocally = true;
#      username = "zoneminder";
#    };
#    hostname = "zoneminder.daniel.fullmer.me";
#  };
#  services.nginx.virtualHosts."${config.services.zoneminder.hostname}" = {
#    default = lib.mkForce false; # Override some defaults set in nixos module
#  };
}
