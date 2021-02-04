{ pkgs, controlnetModules, ...} : {
  name = "desktop";

  machine = { config, pkgs, ... }: {
    imports = [
      ../profiles/base.nix
      ../profiles/interactive.nix
      ../profiles/desktop/default.nix
      ../profiles/autologin.nix
    ] ++ controlnetModules;
    environment.systemPackages = with pkgs; [ awf termite ];
  };

  testScript =
    ''
      machine.wait_for_x()
      machine.wait_for_file("/home/danielrf/.Xauthority")
      machine.succeed("xauth merge ~danielrf/.Xauthority")
      machine.wait_for_window("i3bar")
      machine.sleep(5)
      machine.screenshot("startup")

      machine.succeed("su - danielrf -s /bin/sh -c 'DISPLAY=:0 termite -t Termite &'")
      machine.wait_for_window("Termite")
      machine.sleep(5)
      machine.screenshot("terminal")
      machine.succeed("su - danielrf -s /bin/sh -c 'kill `pgrep termite`'")

      machine.succeed(
          "su - danielrf -s /bin/sh -c 'DISPLAY=:0 termite -t Termite -e \"vim ${./desktop.nix}\" --hold &'"
      )
      machine.wait_for_window("Termite")
      machine.sleep(5)
      machine.screenshot("vim")
      machine.succeed("su - danielrf -s /bin/sh -c 'kill `pgrep termite`'")

      machine.succeed("su - danielrf -s /bin/sh -c 'DISPLAY=:0 awf-gtk2 &'")
      machine.wait_for_window("A widget factory.*Gtk2")
      machine.sleep(5)
      machine.screenshot("gtk2widgets")
      machine.succeed("su - danielrf -s /bin/sh -c 'kill `pgrep awf-gtk`'")

      machine.succeed("su - danielrf -s /bin/sh -c 'DISPLAY=:0 awf-gtk3 &'")
      machine.wait_for_window("A widget factory.*Gtk3")
      machine.sleep(5)
      machine.screenshot("gtk3widgets")
      machine.succeed("su - danielrf -s /bin/sh -c 'kill `pgrep awf-gtk`'")
    '';
}
