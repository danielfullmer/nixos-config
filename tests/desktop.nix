{ pkgs, controlnetModules, ...} : {
  name = "desktop";

  nodes.machine = { config, pkgs, ... }: {
    imports = [
      ../profiles/base.nix
      ../profiles/interactive.nix
      ../profiles/desktop/default.nix
      ../profiles/autologin.nix
    ] ++ controlnetModules;

    # The autologin and test script assume this user exists; on real
    # machines it is created by home-manager, but the test VM has none.
    users.users.danielrf.isNormalUser = true;

    environment.systemPackages = with pkgs; [ awf kitty ];
  };

  testScript =
    ''
      machine.wait_for_x()
      machine.wait_for_file("/home/danielrf/.Xauthority")
      machine.succeed("xauth merge ~danielrf/.Xauthority")
      machine.wait_for_window("i3bar")
      machine.sleep(5)
      machine.screenshot("startup")

      machine.succeed("su - danielrf -s /bin/sh -c 'DISPLAY=:0 kitty -T Kitty > /dev/null 2>&1 &'")
      machine.wait_for_window("Kitty")
      machine.sleep(5)
      machine.screenshot("terminal")
      machine.succeed("su - danielrf -s /bin/sh -c 'kill `pgrep kitty`'")

      machine.succeed(
          "su - danielrf -s /bin/sh -c 'DISPLAY=:0 kitty -T Kitty --hold vim ${./desktop.nix} > /dev/null 2>&1 &'"
      )
      machine.wait_for_window("Kitty")
      machine.sleep(5)
      machine.screenshot("vim")
      machine.succeed("su - danielrf -s /bin/sh -c 'kill `pgrep kitty`'")

      machine.succeed("su - danielrf -s /bin/sh -c 'DISPLAY=:0 awf-gtk2 > /dev/null 2>&1 &'")
      machine.wait_for_window("A widget factory.*Gtk2")
      machine.sleep(5)
      machine.screenshot("gtk2widgets")
      machine.succeed("su - danielrf -s /bin/sh -c 'kill `pgrep awf-gtk`'")

      machine.succeed("su - danielrf -s /bin/sh -c 'DISPLAY=:0 awf-gtk3 > /dev/null 2>&1 &'")
      machine.wait_for_window("A widget factory.*Gtk3")
      machine.sleep(5)
      machine.screenshot("gtk3widgets")
      machine.succeed("su - danielrf -s /bin/sh -c 'kill `pgrep awf-gtk`'")
    '';
}
