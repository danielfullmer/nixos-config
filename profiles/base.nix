{ config, pkgs, lib, ... }:

{
  imports = [
    ../modules
    ../pkgs/custom-config.nix
  ];

  # Save some space by only supporting a few locales
  i18n.supportedLocales = ["en_US.UTF-8/UTF-8" "en_US/ISO-8859-1"];

  services.openssh.enable = true;
  #services.fail2ban.enable = true; # Currently causes problems restarting, See fail2ban PR 1618. nixpkgs out of date

  boot.cleanTmpDir = true;

  programs.ssh.knownHosts."github.com".publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==";
  # X11 and GPG forwarding for SSH
  # See https://wiki.gnupg.org/AgentForwarding
  # TODO: /run/user/ path is not correct if UID is different across hosts
  #programs.ssh.extraConfig = ''
  #  Host ${concatStringsSep " " (attrNames config.machines.sshPublicKey)}
  #  #ForwardAgent yes
  #  ForwardX11 yes
  #  #RemoteForward /run/user/1000/gnupg/S.gpg-agent /run/user/1000/gnupg/S.gpg-agent.extra
  #'';
  #services.openssh.forwardX11 = !config.environment.noXlibs;
  #services.openssh.extraConfig = ''
  #  StreamLocalBindUnlink yes
  #'';

  nix = {
    package = pkgs.nixFlake;

    autoOptimiseStore = true;
    useSandbox = true;
    trustedUsers = [ "root" ];

    daemonIOSchedPriority = 5; # Range: 0-7
    daemonCPUSchedPolicy = "batch";

    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  time.timeZone = "America/Los_Angeles";
  time.hardwareClockInLocalTime = true;

  nixpkgs.config = import ../pkgs/config.nix;
  nixpkgs.overlays =  [ (import ../pkgs/overlay.nix { _config=config; }) ];
}
