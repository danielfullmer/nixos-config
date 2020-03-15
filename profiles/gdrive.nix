{ config, pkgs, lib, ... }:

# https://github.com/rclone/rclone/wiki/rclone-fstab-mount-helper-script
{
  programs.fuse.userAllowOther = true;

  systemd.services = lib.genAttrs [ "gdrive" "gdrive-enc" "gdrive2" "gdrive2-enc" ] (remote: {
    requires = [ "network-online.target"] ;
    after = [ "network-online.target" ];
    script = "${lib.getBin pkgs.rclone}/bin/rclone mount ${remote}: /mnt/${remote} --allow-other --config /etc/rclone.conf";
    postStop = "${pkgs.fuse}/bin/fusermount -z /mnt/${remote}";
    path = [ pkgs.fuse ];
    serviceConfig.Type = "notify";
  });

  environment.systemPackages = with pkgs; [ rclone ];

  environment.etc."rclone.conf".source = "/var/secrets/rclone.conf";
  secrets."rclone.conf" = {};
}
