import <nixpkgs/nixos/tests/make-test.nix> ({ pkgs, ...} : {
  name = "desktop";

  machine = { config, pkgs, ... }: {
    imports = [
      ../profiles/base.nix
      ../profiles/desktop.nix
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
