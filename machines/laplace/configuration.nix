{ config, pkgs, lib, ... }:

with lib;
let
  pinebook_pro = import ((builtins.fetchGit {
      url = "https://github.com/samueldr/wip-pinebook-pro.git";
      rev = "59568ca1d40777b957e2106c266c9f248b671f9d";
    }) + "/pinebook_pro.nix");
in
{
  imports = [
    ../../profiles/base.nix
    ../../profiles/interactive.nix
    ../../profiles/extended.nix
    ../../profiles/yubikey.nix
    #../../profiles/syncthing.nix
    ../../profiles/desktop/default.nix
    #../../profiles/academic.nix
    #../../profiles/gdrive.nix

    pinebook_pro
  ];

  networking.hostName = "laplace";
  networking.hostId = "36e832af";

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  networking.networkmanager.enable = true;

  programs.light.enable = true;

  services.xserver.videoDrivers = [ "modesetting" ];
  services.xserver.libinput = {
    enable = true;
    accelSpeed = "0.35";
  };

  theme.fontSize = 12;

  services.redshift.enable = true;

  # For some reason, this is not enabled by default for aarch64: https://github.com/NixOS/nixpkgs/issues/61602
#  boot.kernelPatches = [
#    { name = "ip_multi";
#      patch = "";
#      extraConfig = ''
#        IP_ADVANCED_ROUTER y
#        IP_MULTIPLE_TABLES y
#        IP_ROUTE_MULTIPATH y
#        IP_ROUTE_VERBOSE y
#      '';
#    }
#  ];

  programs.chromium.extensions = [ "aleakchihdccplidncghkekgioiakgal" ]; # h264ify
}
