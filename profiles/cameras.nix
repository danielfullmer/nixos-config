{ config, pkgs, lib, ... }:

lib.mkMerge [
{
  # Stuff for streaming cameras?
  # Currently unencrypted. Maybe fix in the future?
  # https://github.com/arut/nginx-rtmp-module/wiki/Directives#hls
  # TODO: Need to mkdir and chown in startup
  # Can watch rtmp without latency of HLS using e.g. mpv --no-buffer "rtmp://bellman/live/ender3"
  #services.nginx.appendConfig = ''
  #  rtmp {
  #    server {
  #      listen 1935;
  #      chunk_size 4096;

  #      application live {
  #        live on;
  #        record off;
  #        hls on;
  #        hls_path /dev/shm/hls;
  #        hls_fragment 2s;
  #        hls_playlist_length 10s;
  #      }
  #    }
  #  }
  #'';
  #services.nginx.virtualHosts."daniel.fullmer.me" = {
  #  locations."/cameras".public = false;
  #  locations."/cameras/hls/" = {
  #    alias = "/dev/shm/hls/";
  #    extraConfig = ''
  #      types {
  #        application/vnd.apple.mpegurl m3u8;
  #        video/mp2t ts;
  #      }
  #      add_header Cache-Control no-cache;
  #    '';
  #    public = false;
  #  };
  #};

  # vdo.ninja. Formerly obs.ninja
  # https://github.com/steveseguin/vdo.ninja/blob/master/install.md
  services.nginx.virtualHosts."obs.daniel.fullmer.me" = let
    root = pkgs.fetchFromGitHub {
      owner = "steveseguin";
      repo = "vdo.ninja";
      rev = "142876991001487efe9a11210fbdda7eaa6f294d";
      sha256 = "1fzghm2ib9v2z5gn4dyqqf0zm5pbv4lnspljcyfda40gr5lk9ny6";
    };
  in {
    inherit root;
    public = false;
    extraConfig = lib.mkBefore "allow 192.168.3.0/24;";

    locations."~ ^/([^/]+)/([^/?]+)$" = {
      inherit root;
      tryFiles = "/$1/$2 /$1/$2.html /$1/$2/ /$2 /$2/ /$1/index.html";
      extraConfig = ''
        add_header Access-Control-Allow-Origin *;
      '';
    };

    locations."/" = {
      tryFiles = "$uri $uri.html $uri/ /index.html";
      extraConfig = ''
        if ($request_uri ~ ^/obs/(.*)\.html$) {
                return 302 /obs/$1;
        }
        add_header Access-Control-Allow-Origin *;
      '';
    };
  };

  # Allow clients connected directly to wifi AP to access this
  services.dnsmasq.extraConfig = ''
    address=/obs.daniel.fullmer.me/192.168.3.1
  '';

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

  nixpkgs.overlays = [
    (self: super: {
      # For SRT streaming support
      mpv-unwrapped = super.mpv-unwrapped.override { ffmpeg = self.ffmpeg-full; };
      libvlc = super.libvlc.override { ffmpeg_4 = self.ffmpeg-full; };
    })
  ];

  environment.systemPackages = with pkgs; [
    obs-studio
  ] ++ (with gst_all_1; [ gstreamer gstreamer.dev gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-rtsp-server ]);
}
{
  networking.vlans.cameras = {
    id = 5;
    interface = "enp68s0";
  };

  # Cameras vlan
  networking.interfaces.cameras.ipv4.addresses = [ { address = "192.168.7.1"; prefixLength=24; } ];
  networking.firewall.interfaces.cameras.allowedUDPPorts = [ 53 67 ]; # DNS and DHCP
  # TODO: Firewall individual devices
  services.dnsmasq = {
    enable = true;
    extraConfig = ''
      interface=cameras
      dhcp-range=interface:cameras,192.168.7.2,192.168.7.254
      dhcp-host=24:52:6a:2d:f0:bc,192.168.7.2,gym-cam
      dhcp-host=6c:1c:71:93:a1:a7,192.168.7.3,garage-cam
      dhcp-host=6c:1c:71:93:a1:d0,192.168.7.4,stair-cam
    '';
  };

  services.rtsp-simple-server = {
    enable = true;
    settings = {
      paths = {
        gym-cam.source = "rtsp://anon:insecure1@192.168.7.2:554/cam/realmonitor?channel=1&subtype=0";
        garage-cam.source = "rtsp://anon:insecure1@192.168.7.3:554/cam/realmonitor?channel=1&subtype=0";
        stair-cam.source = "rtsp://anon:insecure1@192.168.7.4:554/cam/realmonitor?channel=1&subtype=0";
      };
    };
  };
}
]
