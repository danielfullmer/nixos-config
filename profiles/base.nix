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

  programs.ssh.knownHosts."github.com".publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=";
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
    package = pkgs.nixFlakes;

    settings = {
      auto-optimise-store = true;
      trusted-users = [ "root" ];

      experimental-features = [ "nix-command" "flakes" ];
    };

    daemonIOSchedPriority = 5; # Range: 0-7
    daemonCPUSchedPolicy = "batch";
  };

  time.timeZone = "America/Los_Angeles";
  time.hardwareClockInLocalTime = true;

  nixpkgs.config = import ../pkgs/config.nix;
  nixpkgs.overlays =  [ (import ../pkgs/overlay.nix { _config=config; }) ];
}
