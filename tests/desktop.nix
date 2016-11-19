let
  theme = (import ../themes);
in
import <nixpkgs/nixos/tests/make-test.nix> ({ pkgs, ...} : {
  name = "desktop";

  machine = { config, pkgs, ... }: {
    imports = [
      (import ../profiles/base.nix { inherit theme; })
      (import ../profiles/desktop.nix { inherit theme; })
      ../profiles/autologin.nix
      ../profiles/homedir.nix
    ];
  };

  testScript =
    ''
      $machine->waitForX;
      $machine->sleep(5);
      $machine->sendKeys("alt-ret");
      $machine->sleep(5);
      $machine->sendChars("hello\n");
      $machine->screenshot("screenshot");
    '';
})
