{ config, pkgs, lib, ... }:
{
  hardware.opengl.driSupport32Bit = true; # Needed for steam

  services.xserver.modules = [ pkgs.xlibs.xf86inputjoystick ];

  environment.systemPackages = (with pkgs; [
    steam
    steamcontroller-udev-rules
  ]);

  # Steam controller stuff
  nixpkgs.config.packageOverrides = pkgs: {
    steamcontroller-udev-rules = pkgs.writeTextFile {
      name = "steamcontroller-udev-rules";
      text = ''
        # This rule is needed for basic functionality of the controller in Steam and keyboard/mouse emulation
        SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", MODE="0666"

        # This rule is necessary for gamepad emulation; make sure you replace 'pgriffais' with a group that the user that runs Steam belongs to
        KERNEL=="uinput", MODE="0660", GROUP="wheel", OPTIONS+="static_node=uinput"

        # Valve HID devices over USB hidraw
        KERNEL=="hidraw*", ATTRS{idVendor}=="28de", MODE="0666"

        # Valve HID devices over bluetooth hidraw
        KERNEL=="hidraw*", KERNELS=="*28DE:*", MODE="0666"

        # DualShock 4 over USB hidraw
        KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="05c4", MODE="0666"

        # DualShock 4 wireless adapter over USB hidraw
        KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ba0", MODE="0666"

        # DualShock 4 Slim over USB hidraw
        KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="09cc", MODE="0666"

        # DualShock 4 over bluetooth hidraw
        KERNEL=="hidraw*", KERNELS=="*054C:05C4*", MODE="0666"

        # DualShock 4 Slim over bluetooth hidraw
        KERNEL=="hidraw*", KERNELS=="*054C:09CC*", MODE="0666"

        # HTC Vive HID Sensor naming and permissioning
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0bb4", ATTRS{idProduct}=="2c87", MODE="0666"
      '';
      destination = "/etc/udev/rules.d/99-steamcontroller.rules";
    };
  };

  services.udev.packages = [ pkgs.steamcontroller-udev-rules ];
}
