{ pkgs, ...} :

let
  # The machine's `pkgs` module argument can't be evaluated while its module
  # imports are being collected (infinite recursion), so locate the nixpkgs
  # test modules via the test's own `pkgs`, which point at the same source.
  testPkgsPath = pkgs.path;
in
{
  name = "gpg-agent-x11";

  nodes.machine =
    { config, pkgs, lib, ... }:
    {
      imports = [ "${testPkgsPath}/nixos/tests/common/x11.nix" ];

      programs.ssh.startAgent = false;
      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
        pinentryPackage = pkgs.pinentry-gtk2; # TODO: Make it work with "gnome3"
      };

      # gpg-agent runs as a systemd user service and does not inherit the
      # X session's environment; pinentry-gtk2 needs DISPLAY to open its
      # window on the autologin display.
      systemd.user.services.gpg-agent.serviceConfig.Environment = [ "DISPLAY=:0" ];

      environment.systemPackages = [ pkgs.gnupg ];

      # XXX: Hack
      system.activationScripts.root-gnupg = "mkdir -p /root/.gnupg";
    };

  testScript =
      ''
      machine.wait_for_x()

      # Ask the gpg-agent for a passphrase so that it launches the GUI
      # pinentry on the X display. The request is started in the background
      # with its stdio detached from the test driver: machine.succeed returns
      # immediately (the driver would otherwise block on the pipe held open by
      # the still-running gpg-connect-agent) while pinentry stays open.
      with subtest("Pinentry"):
          # Start from a clean slate: a stale pinentry request would hold
          # the agent's pinentry lock and make our request time out after
          # the 60s lock timeout without ever showing a window.
          machine.succeed(
              "XDG_RUNTIME_DIR=/run/user/0 systemctl --user restart gpg-agent"
          )
          machine.sleep(1)
          machine.succeed(
              "DISPLAY=:0 gpg-connect-agent 'get_passphrase x Invalid Prompt Description' /bye > /dev/null 2>&1 < /dev/null &"
          )
          # pinentry titles its dialog window after the client that requested
          # the passphrase, e.g. "[1234]@machine (gpg-connect-agent
          # get_passphrase x Invalid Prompt Description /bye)".
          machine.wait_for_window(r"\[\d+\]@machine \(gpg-connect-agent get_passphrase")
          machine.sleep(2)
          machine.screenshot("pinentry")
    '';
}
