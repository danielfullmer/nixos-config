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

  boot.tmp.cleanOnBoot = true;

  programs.ssh.knownHosts = {
    "github.com".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
    "github.com/ecdsa" = { hostNames = [ "github.com" ]; publicKey = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT"; };
    "github.com/rsa" = { hostNames = [ "github.com" ]; publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt"; };
  };
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
