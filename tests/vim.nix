import <nixpkgs/nixos/tests/make-test-python.nix> ({ pkgs, ...} :

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
      machine.wait_for_unit("multi-user.target")
      machine.wait_until_succeeds("pgrep -f 'agetty.*tty1'")

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

      # Start up VIM and write an empty file
      with subtest("vim"):
          machine.send_chars("vim\n")
          machine.sleep(5)
          machine.screenshot("vim")
          machine.send_chars(":w test\n")
          machine.wait_for_file("/home/alice/test")
    '';
})
