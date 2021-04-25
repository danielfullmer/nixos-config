{ ... }:

{
  ### Stuff for cuttlefish ###
  # Is this necessary? Wouldn't it be autoloaded on use? Doesn't seem to be
  boot.kernelModules = [ "vhci-hcd" "vhost_net" "vhost_vsock" ];

  # Copied from android-cuttlefish/debian/cuttlefish-common.udev
  # TODO: We can probably do better than this...
  services.udev.extraRules = ''
    ACTION=="add", KERNEL=="vhost-net", SUBSYSTEM=="misc", MODE="0660", GROUP="cvdnetwork"
    ACTION=="add", KERNEL=="vhost-vsock", SUBSYSTEM=="misc", MODE="0660", GROUP="cvdnetwork"
  '';

  users.groups.cvdnetwork = {};
  users.users.danielrf.extraGroups = [ "kvm" "cvdnetwork" ];
}
