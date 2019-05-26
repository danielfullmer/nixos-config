# Just an attrset with details that should be shared in some way between hosts.
# TODO: Maybe refactor this into a deployment in nixops/morph?
{
  zerotierIP = {
    bellman = "30.0.0.222";
    nyquist = "30.0.0.127";
    euler = "30.0.0.86";
    banach = "30.0.0.156";
    gauss = "30.0.0.84";
    spaceheater = "30.0.0.40";

    sysc-2 = "30.0.0.154";
    wrench = "30.0.0.34";
    devnull = "30.0.0.48";

    pixel = "30.0.0.248";
  };

  sshPublicKey = {
    bellman = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII3vpFuoazTclho9ew0EFP+QhanahZtASGBCUk5oxBGW";
    nyquist = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBEOwL+5XKdvVBNGIT4pUfzNtMyvuvERwWAcE9q8HFVj";
    banach = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKGfJCTIzSct/m/Zm/yUb224JhKmr35ISH2CEcxSbkCc";
    wrench = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBM6M2q7YcOoHWQRpok1euwQ8FChG34GxxlijFtLHL6uO2myUpstpfvaF4K0Rm5rkiaXGmFZAjgj132JO98JbL1k=";
  };

  syncthingID = {
    bellman = "BVJ7MGT-A4S3AST-MOI4ROZ-KVNQM5J-34N5IJQ-JIEUFJR-KFEA7HF-RIDQOQJ";
    euler = "V6FOL26-QXGNP4E-25OQLVP-BW7TNIL-Q6KWDHC-56UGUZ7-7PY3DWA-KPN2QQ4";
    sysc-2 = "SVORZYT-B75D76Z-JTLBU64-CAV3QR2-IMLOCLG-CPJPNO7-UELWC5U-SAI5CQV";
  };
}
