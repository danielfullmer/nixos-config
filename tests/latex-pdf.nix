import <nixpkgs/nixos/tests/make-test-python.nix> ({ pkgs, ...} : {
  name = "latex-pdf";

  machine = { config, pkgs, ... }: {
    imports = [
      ../profiles/base.nix
      ../profiles/interactive.nix
      ../profiles/desktop/default.nix
      ../profiles/academic.nix
      ../profiles/autologin.nix
    ];
    virtualisation.memorySize = 1024;
  };

  enableOCR = true;

  testScript =
    ''
      machine.wait_for_x()
      machine.wait_for_file("/home/danielrf/.Xauthority")
      machine.succeed("xauth merge ~danielrf/.Xauthority")
      machine.wait_for_window("i3bar")
      machine.sleep(5)

      machine.succeed(
          "su - danielrf -s /bin/sh -c 'cp ${./latex-pdf.tex} /home/danielrf/latex-pdf.tex'"
      )
      machine.succeed("su - danielrf -s /bin/sh -c 'latexmk /home/danielrf/latex-pdf.tex &'")
      machine.wait_for_window("zathura")
      machine.sleep(5)
      machine.screenshot("zathura")
    '';
})
