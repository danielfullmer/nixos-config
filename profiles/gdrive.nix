{ config, pkgs, lib, ... }:
let rclonemount = pkgs.writeScript "rclonemount" ''
  # Need this path to run "fusermount"
  export PATH=${pkgs.fuse}/bin:$PATH

  # TODO: Remove & when rclone implements a background option (See issue #723)
  ${pkgs.rclone}/bin/rclone mount "$1" "$2" --allow-other --config /etc/rclone.conf &
'';
in
{
  environment.etc."fuse.conf".text = ''
    user_allow_other
  '';

  fileSystems = builtins.listToAttrs (map (remote: {
    name = "/mnt/${remote}";
    value = {
      device = "${rclonemount}#${remote}:";
        fsType = "fuse";
        options = [ "_netdev" ];
        noCheck = true;
    };
  }) [ "gdrive" "gdrive-enc" "gdrive2" "gdrive2-enc" ]);

  environment.systemPackages = with pkgs; [ rclone ];
}
