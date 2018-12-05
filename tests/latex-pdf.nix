import <nixpkgs/nixos/tests/make-test.nix> ({ pkgs, ...} : {
  name = "latex-pdf";

  machine = { config, pkgs, ... }: {
    imports = [
      ../profiles/base.nix
      ../profiles/desktop/default.nix
      ../profiles/academic.nix
      ../profiles/autologin.nix
    ];
    virtualisation.memorySize = 1024;
  };

  enableOCR = true;

  testScript =
    ''
      $machine->waitForX;
      $machine->waitForFile("/home/danielrf/.Xauthority");
      $machine->succeed("xauth merge ~danielrf/.Xauthority");
      $machine->waitForWindow(qr/i3bar/);
      $machine->sleep(5);

      $machine->succeed("su - danielrf -s /bin/sh -c 'cp ${./latex-pdf.tex} /home/danielrf/latex-pdf.tex'");
      $machine->succeed("su - danielrf -s /bin/sh -c 'latexmk /home/danielrf/latex-pdf.tex &'");
      $machine->waitForWindow(qr/zathura/);
      $machine->sleep(5);
      $machine->screenshot("zathura");
    '';
})
