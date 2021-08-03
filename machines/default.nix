# Module with machine=specific details that should be shared in some way between hosts.
{ config, pkgs, lib, ... }:

with lib;
let
  cfg = config.machines;
in
{
  options.machines = lib.mkOption {
    type = lib.types.attrs;
    default = {};
  };

  config = mkMerge [ {
    machines = {
      zerotierIP = {
        bellman = "30.0.0.222";
        euler = "30.0.0.86";
        euler-win = "30.0.0.205";
        gauss = "30.0.0.84";
        spaceheater = "30.0.0.40";

        banach = "30.0.0.156";
        tarski = "30.0.0.32";

        wrench = "30.0.0.14";
        devnull = "30.0.0.48";

        pixel3 = "30.0.0.248";

        # AHT work machines
        hercules = "192.168.192.71";
      };

      wireguardIP = {
        gauss = "10.200.0.1";
        bellman = "10.200.0.2";
        pixel3 = "10.200.0.3";
      };

      virtualHosts = {
        bellman = (map (name: "${name}.daniel.fullmer.me") [
          "attestation" "hydra" "playmaker" "fdroid" "office" "zoneminder" "home"
          "grocy"
        ]) ++ [ "daniel.fullmer.me" "nextcloud.fullmer.me" ];
        gauss = [ "searx.daniel.fullmer.me" ];
        banach = [ "printer.daniel.fullmer.me" ];
        hercules = [ "gitlab.aht.ai" "ng911-demo.aht.ai" ];
        wrench = [ "wrench.fullmer.me" ];
      };

      publicVirtualHosts = [ "daniel.fullmer.me" ];

      sshPublicKey = {
        bellman = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII3vpFuoazTclho9ew0EFP+QhanahZtASGBCUk5oxBGW";
        banach = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKGfJCTIzSct/m/Zm/yUb224JhKmr35ISH2CEcxSbkCc";
        gauss = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHsBoQtQeyvKK0IHewwwesgxiiiwxzx5bUqBNKGU3Xuu";
        wrench = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINEWKX4iWNnZ1sGLWYo8zzoEflXt/USVrYbZReA1smCc";
      };

      syncthingID = {
        bellman = "BVJ7MGT-A4S3AST-MOI4ROZ-KVNQM5J-34N5IJQ-JIEUFJR-KFEA7HF-RIDQOQJ";
        euler = "V6FOL26-QXGNP4E-25OQLVP-BW7TNIL-Q6KWDHC-56UGUZ7-7PY3DWA-KPN2QQ4";
        euler-win = "QUOVAFW-OIB56KE-JIFL5TT-EXXANDK-L7GVNSH-JBT72WI-NTY5ZOO-R2SBDAN";
      };
    };
  }

  (mkIf config.services.zerotierone.enable {
    # Set up /etc/hosts to use zerotier IP addresses for the virtualHosts
    networking.hosts = mkMerge [
      (mapAttrs' (machine: ip: nameValuePair ip [ machine ]) cfg.zerotierIP)
      (mapAttrs' (machine: virtualHosts: nameValuePair cfg.zerotierIP.${machine} virtualHosts) cfg.virtualHosts)
      { "${config.machines.zerotierIP.wrench}" = [ "wrench.fullmer.me" ]; }
    ];
  })
  {
    programs.ssh.knownHosts = lib.mapAttrs (machine: publicKey: { inherit publicKey; }) cfg.sshPublicKey;
  }
  ];
}
