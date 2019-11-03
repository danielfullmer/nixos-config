{ config, pkgs, lib, ... }:

# https://github.com/rclone/rclone/wiki/rclone-fstab-mount-helper-script
let rclonemount = pkgs.writeScript "rclonemount" ''
  # Need this path to run "fusermount"
  export PATH=${pkgs.fuse}/bin:$PATH

  # TODO: Remove & when rclone implements a background option (See issue #723)
  ${lib.getBin pkgs.rclone}/bin/rclone mount "$1" "$2" --allow-other --config /etc/rclone.conf &
  sleep 1 # Should be enough time for the mount to complete before returning
'';
in
{
  environment.etc."fuse.conf".text = ''
    user_allow_other
  '';

  systemd.mounts = (map (remote: {
    what = "${rclonemount}#${remote}:";
    where = "/mnt/${remote}";
    type = "fuse";
    options = "_netdev,nofail"; # nofail makes it wanted, but not required, by remote-fs.target
  }) [ "gdrive" "gdrive-enc" "gdrive2" "gdrive2-enc" ]);

  environment.systemPackages = with pkgs; [ rclone ];

  environment.etc."rclone.conf".source = "/var/secrets/rclone.conf";
  secrets."rclone.conf" = {};
}
