import <nixpkgs/nixos/tests/make-test.nix> ({ pkgs, ...} :

{
  name = "gpg-agent-x11";

  machine =
    { config, pkgs, lib, ... }:
    {
      imports = [ <nixpkgs/nixos/tests/common/x11.nix> ];

      programs.ssh.startAgent = false;
      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
        pinentryFlavor = "gtk2"; # TODO: Make it work with "gnome3"
      };

      environment.systemPackages = [ pkgs.gnupg ];

      # XXX: Hack
      system.activationScripts.root-gnupg = "mkdir -p /root/.gnupg";
    };

  testScript =
      ''
      $machine->waitForX;

      # Ensure pinentry shows up in X11;
      subtest "Pinentry", sub {
          $machine->succeed("DISPLAY=:0 gpg-connect-agent 'get_passphrase x Invalid Prompt Description' /bye &\n");
          $machine->waitForWindow("^pinentry");
          $machine->screenshot("pinentry");
      };
    '';
})
