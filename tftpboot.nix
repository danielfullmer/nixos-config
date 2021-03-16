{ pkgs,  pxeSystems ? {} }:

# Pass mac address as key, nixos system as value
let
  # Small modification to upstream, as uboot's pxe/extlinux support seems to do all paths relative to tftpRoot. Try to keep in sync
  extlinux-conf-builder = import ./generic-extlinux-compatible/extlinux-conf-builder.nix { inherit pkgs; };
  extlinuxFiles = system: pkgs.runCommand "extlinuxFiles" {} ''
    mkdir -p $out
    ${extlinux-conf-builder} -t 3 -c ${system.build.toplevel} -d $out
  '';
in pkgs.runCommand "tftp-root" {} (''
  mkdir -p $out
  mkdir -p $out/pxelinux.cfg
'' + (pkgs.lib.concatStringsSep "\n" (pkgs.lib.mapAttrsToList (mac: system: ''
  cp    ${extlinuxFiles system.config.system}/extlinux/extlinux.conf $out/pxelinux.cfg/${mac}
  cp -r ${extlinuxFiles system.config.system}/nixos $out/
'') pxeSystems)))
