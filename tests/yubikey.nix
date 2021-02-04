{ pkgs, ...} : {
  name = "yubikey";

  machine = { config, pkgs, ... }: {
    imports = [
      ../profiles/base.nix
      ../profiles/yubikey.nix
    ];

    # Running this test requires the yubikey to be inserted and
    # write access to the device under /dev/bus/usb/.../...
    virtualisation.qemu.options = [
      "-usb"
      "-usbdevice host:1050:0115"
    ];
  };

  testScript = ''
    machine.wait_for_unit("multi-user.target")
    machine.succeed("su - danielrf -s /bin/sh -c 'gpg2 --card-status'")

    # TODO: Come up with test for u2f, ykpersonalize, and yubioath-gui
  '';
}
