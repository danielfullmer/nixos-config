import <nixpkgs/nixos/tests/make-test.nix> ({ pkgs, ...} :

{
  name = "vim";

  machine =
    { config, pkgs, lib, ... }:
    {
      nixpkgs.overlays = (import ../pkgs/overlays.nix);
      environment.systemPackages = [ pkgs.neovim pkgs.git ]; # Gitgutter nees git
    };

  enableOCR=true;

  # Part of this cribbed from login.nix
  testScript =
    ''
      $machine->waitForUnit('multi-user.target');
      $machine->waitUntilSucceeds("pgrep -f 'agetty.*tty1'");

      subtest "create user", sub {
          $machine->succeed("useradd -m alice");
          $machine->succeed("(echo foobar; echo foobar) | passwd alice");
      };

      # Log in as alice on a virtual console.
      subtest "virtual console login", sub {
          $machine->waitUntilTTYMatches(1, "login: ");
          $machine->sendChars("alice\n");
          $machine->waitUntilTTYMatches(1, "login: alice");
          $machine->waitUntilSucceeds("pgrep login");
          $machine->waitUntilTTYMatches(1, "Password: ");
          $machine->sendChars("foobar\n");
          $machine->waitUntilSucceeds("pgrep -u alice bash");
          $machine->sendChars("touch done\n");
          $machine->waitForFile("/home/alice/done");
      };

      # Start up VIM and write an empty file
      subtest "vim", sub {
          $machine->sendChars("vim\n");
          $machine->sleep(5);
          $machine->screenshot("vim");
          $machine->sendChars(":w test\n");
          $machine->waitForFile("/home/alice/test");
      };
    '';
})
