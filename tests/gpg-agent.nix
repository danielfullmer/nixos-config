import <nixpkgs/nixos/tests/make-test-python.nix> ({ pkgs, ...} :

{
  name = "gpg-agent";

  machine =
    { config, pkgs, lib, ... }:
    {
      programs.ssh.startAgent = false;
      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
        pinentryFlavor = "curses";
      };

      environment.systemPackages = [ pkgs.gnupg ];

      # XXX: Hack
      system.activationScripts.root-gnupg = "mkdir -p /root/.gnupg";
    };

  # Part of this cribbed from login.nix
  testScript =
    ''
      machine.wait_for_unit("multi-user.target")
      machine.wait_until_succeeds("pgrep -f 'agetty.*tty1'")
      machine.screenshot("postboot")

      with subtest("create user"):
          machine.succeed("useradd -m alice")
          machine.succeed("(echo foobar; echo foobar) | passwd alice")

      # Log in as alice on a virtual console.
      with subtest("virtual console login"):
          machine.wait_until_tty_matches(1, "login: ")
          machine.send_chars("alice\n")
          machine.wait_until_tty_matches(1, "login: alice")
          machine.wait_until_succeeds("pgrep login")
          machine.wait_until_tty_matches(1, "Password: ")
          machine.send_chars("foobar\n")
          machine.wait_until_succeeds("pgrep -u alice bash")
          machine.send_chars("touch done\n")
          machine.wait_for_file("/home/alice/done")

      # Ensure pinentry shows up on our tty
      with subtest("Pinentry"):
          machine.send_chars(
              "gpg-connect-agent 'get_passphrase x Invalid Prompt Description' /bye\n"
          )
          machine.wait_until_tty_matches(1, "<OK>")
          machine.screenshot("pinentry")
    '';
})
