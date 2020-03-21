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
        nyquist = "30.0.0.127";
        euler = "30.0.0.86";
        euler-win = "30.0.0.205";
        gauss = "30.0.0.84";
        spaceheater = "30.0.0.40";

        banach = "30.0.0.156";
        tarski = "30.0.0.32";

        sysc-2 = "30.0.0.154";
        wrench = "30.0.0.34";
        devnull = "30.0.0.48";

        pixel3 = "30.0.0.248";
      };

      wireguardIP = {
        gauss = "10.200.0.1";
        bellman = "10.200.0.2";
        pixel3 = "10.200.0.3";
      };

      virtualHosts = {
        bellman = (map (name: "${name}.${config.networking.domain}") [ 
          "attestation" "hydra" "playmaker" "fdroid" "office" "zoneminder" "home"
        ]) ++ [ "daniel.fullmer.me" "nextcloud.fullmer.me" ];
        gauss = [ "searx.${config.networking.domain}" ];
      };

      publicVirtualHosts = [ "daniel.fullmer.me" ];

      sshPublicKey = {
        bellman = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII3vpFuoazTclho9ew0EFP+QhanahZtASGBCUk5oxBGW";
        nyquist = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBEOwL+5XKdvVBNGIT4pUfzNtMyvuvERwWAcE9q8HFVj";
        banach = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKGfJCTIzSct/m/Zm/yUb224JhKmr35ISH2CEcxSbkCc";
        gauss = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHsBoQtQeyvKK0IHewwwesgxiiiwxzx5bUqBNKGU3Xuu";
        wrench = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBM6M2q7YcOoHWQRpok1euwQ8FChG34GxxlijFtLHL6uO2myUpstpfvaF4K0Rm5rkiaXGmFZAjgj132JO98JbL1k=";
      };

      syncthingID = {
        bellman = "BVJ7MGT-A4S3AST-MOI4ROZ-KVNQM5J-34N5IJQ-JIEUFJR-KFEA7HF-RIDQOQJ";
        euler = "V6FOL26-QXGNP4E-25OQLVP-BW7TNIL-Q6KWDHC-56UGUZ7-7PY3DWA-KPN2QQ4";
        euler-win = "QUOVAFW-OIB56KE-JIFL5TT-EXXANDK-L7GVNSH-JBT72WI-NTY5ZOO-R2SBDAN";
        sysc-2 = "SVORZYT-B75D76Z-JTLBU64-CAV3QR2-IMLOCLG-CPJPNO7-UELWC5U-SAI5CQV";
      };
    };
  }

  (mkIf config.services.zerotierone.enable {
    # Set up /etc/hosts to use zerotier IP addresses for the virtualHosts
    networking.hosts = mapAttrs' (machine: ip: nameValuePair ip [ machine ]) cfg.zerotierIP;
  })
  (mkIf config.services.zerotierone.enable {
    networking.hosts = mapAttrs' (machine: virtualHosts: nameValuePair cfg.zerotierIP.${machine} virtualHosts) cfg.virtualHosts;
  })
  {
    programs.ssh.knownHosts = lib.mapAttrs (machine: publicKey: { inherit publicKey; }) cfg.sshPublicKey;
  }
  ];
}
