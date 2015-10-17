import <nixpkgs/nixos/tests/make-test.nix> ({ pkgs, ...} : {
  name = "base";

  machine = { config, pkgs, ... }: {
    imports = [
      ../profiles/base.nix
      ../profiles/yubikey.nix
      ../profiles/desktop.nix
      ../profiles/homedir.nix
    ];
  };

  testScript =
    ''
      startAll;
      $machine->waitForX;
      $machine->sleep(5);
      $machine->sendKeys("alt-ret");
      $machine->sleep(5);
      $machine->sendChars("hello\n");
      $machine->screenshot("screenshot");
    '';
})
