{ config, pkgs, lib, ... }:
let rclonemount = pkgs.writeScript "rclonemount" ''
  # Need this path to run "fusermount"
  export PATH=${pkgs.fuse}/bin:$PATH

  # TODO: Remove & when rclone implements a background option (See issue #723)
  ${pkgs.rclone}/bin/rclone mount "$1" "$2" --no-modtime --allow-other --config /etc/rclone.conf &
'';
in
{
  environment.etc."fuse.conf".text = ''
    user_allow_other
  '';

  fileSystems = {
    "/mnt/gdrive" = {
      device = "${rclonemount}#gdrive:";
      fsType = "fuse";
      options = [ "_netdev" ];
    };
    "/mnt/gdrive-enc" = {
      device = "${rclonemount}#gdrive-enc:";
      fsType = "fuse";
      options = [ "_netdev" ];
    };
    "/mnt/gdrive2" = {
      device = "${rclonemount}#gdrive2:";
      fsType = "fuse";
      options = [ "_netdev" ];
    };
    "/mnt/gdrive2-enc" = {
      device = "${rclonemount}#gdrive2-enc:";
      fsType = "fuse";
      options = [ "_netdev" ];
    };
  };
}
