{ config, pkgs, lib, ... }:
{
  # TOOD: Parameterize
  # Used by hydra even if nix.distributedBuilds is false
  nix.buildMachines = [
    { hostName = "noether";
      sshUser = "nixbuilder";
      sshKey = config.sops.secrets.noether-nixbuilder.path;
      systems = [ "aarch64-linux" "armv7l-linux" ];
      maxJobs = 4;
      supportedFeatures = [ "kvm" "nixos-test" "big-parallel" "benchmark" ];
    }
  ];
  sops.secrets.noether-nixbuilder.sopsFile = ../secrets/secrets.yaml;
  nix.distributedBuilds = true;

  programs.ssh.extraConfig = ''
    Host noether
      ControlMaster auto
      ControlPath ~/.ssh/master-%r@%h:%p
      ControlPersist 30
  '';
}
