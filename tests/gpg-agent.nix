import <nixpkgs/nixos/tests/make-test.nix> ({ pkgs, ...} :

{
  name = "gpg-agent";

  machine =
    { config, pkgs, lib, ... }:
    {
      programs.ssh.startAgent = false;
      programs.gnupg.agent.enable = true;
      programs.gnupg.agent.enableSSHSupport = true;

      environment.systemPackages = [ pkgs.gnupg ];

      # XXX: Hack
      system.activationScripts.root-gnupg = "mkdir -p /root/.gnupg";
    };

  # Part of this cribbed from login.nix
  testScript =
    ''
      $machine->waitForUnit('multi-user.target');
      $machine->waitUntilSucceeds("pgrep -f 'agetty.*tty1'");
      $machine->screenshot("postboot");

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

      # Ensure pinentry shows up on our tty
      subtest "Pinentry", sub {
          $machine->sendChars("gpg-connect-agent 'get_passphrase x Invalid Prompt Description' /bye\n");
          $machine->waitUntilTTYMatches(1, "<OK>");
          $machine->screenshot("pinentry");
      };
    '';
})
