import <nixpkgs/nixos/tests/make-test.nix> ({ pkgs, ...} : {
  name = "desktop";

  machine = { config, pkgs, ... }: {
    imports = [
      ../profiles/base.nix
      ../profiles/desktop/default.nix
      ../profiles/autologin.nix
      ../profiles/homedir.nix
    ];
  };

  # Use our overrides for neofetch
  testScript = with pkgs // (import ../pkgs { inherit pkgs; });
    ''
      $machine->waitForX;
      $machine->waitForFile("/home/danielrf/.Xauthority");
      $machine->succeed("xauth merge ~danielrf/.Xauthority");
      $machine->waitForWindow(qr/i3bar/);
      $machine->sleep(5);
      $machine->screenshot("startup");

      # Need to explicitly reference the config file
      $machine->succeed("su - danielrf -s /bin/sh -c 'DISPLAY=:0 ${termite}/bin/termite -t Termite -e \"${neofetch}/bin/neofetch --config ${neofetch}/share/neofetch/config\" --hold &'");
      $machine->waitForWindow(qr/Termite/);
      $machine->sleep(10);
      $machine->screenshot("terminal");
      $machine->succeed("su - danielrf -s /bin/sh -c 'kill `pgrep termite`'");

      $machine->succeed("su - danielrf -s /bin/sh -c 'DISPLAY=:0 ${awf}/bin/awf-gtk2 &'");
      $machine->succeed("su - danielrf -s /bin/sh -c 'DISPLAY=:0 ${awf}/bin/awf-gtk3 &'");
      $machine->waitForWindow(qr/A widget factory.*Gtk2/);
      $machine->waitForWindow(qr/A widget factory.*Gtk3/);
      $machine->sleep(5);
      $machine->screenshot("gtkwidgets");
      $machine->succeed("su - danielrf -s /bin/sh -c 'kill `pgrep awf-gtk`'");
    '';
})
