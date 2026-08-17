{ pkgs, controlnetModules, ...} :
{
  name = "latex-pdf";

  nodes.machine = { config, pkgs, ... }: {
    imports = [
      ../profiles/base.nix
      ../profiles/interactive.nix
      ../profiles/desktop/default.nix
      ../profiles/academic.nix
      ../profiles/autologin.nix
    ] ++ controlnetModules;
    virtualisation.memorySize = 1024;

    # The autologin and test script assume this user exists; on real
    # machines it is created by home-manager/personal.nix, but the
    # test VM has none of that. Mirror the user+group definitions.
    users.groups.danielrf = { };
    users.users.danielrf = {
      isNormalUser = true;
      group = "danielrf";
    };
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
          "su - danielrf -s /bin/sh -c 'cp ${../dotfiles/.latexmkrc} /home/danielrf/.latexmkrc'"
      )
      machine.succeed(
          "su - danielrf -s /bin/sh -c 'cp ${./latex-pdf.tex} /home/danielrf/latex-pdf.tex'"
      )
      # latexmk keeps running in continuous-preview mode and launches the
      # previewer, so it must not hold the shell's stdout open.
      machine.succeed(
          "su - danielrf -s /bin/sh -c 'DISPLAY=:0 latexmk /home/danielrf/latex-pdf.tex > /dev/null 2>&1 &'"
      )
      machine.wait_for_window("zathura")
      machine.sleep(5)
      machine.screenshot("zathura")
    '';
}
