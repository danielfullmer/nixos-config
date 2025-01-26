# Personalizations that should only apply to home accounts, not work
{ config, lib, pkgs, ... }:

let
  ssh-yubikey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDMTGWu4gkXsWewBZg5if04qt5lyEAKwhi12wmn5e2hKvVLlTlIq8gGBF7d/Xv8G2NlHRsNkugeYyBtB2qfkPWtcDnd1+ws78UTUbYDPpZJzRnIjUEzAg8Q5DzgD9feGHmpONmsr6K71ZGJFwQH2Vf8RHzYIzAYPY85raQiV2Akpw9QtWjp48sNUKoJ75ZWZWzQdJtouJYZRnrK+gweKVWFB0cv7qrIgSOFHAjGJLON+cMXN+T/VIDSZITCRcVLBMlYYGv5NZecspRPO1UV0bgWNHZ3dZwJOEk6cPYUdyA/761zhCWCUc7MJH5xEz3sxcqBSmxtwFYvDFDWkWYcD1gh yubikey";
  ssh-yubikey2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG43uYxPOPoN1mAD16DDsB3dp0r6C0X40CGssBTeft33 yubikey2";
in
{
  imports = [ ../machines ];

  sops.defaultSopsFile = ../machines + "/${config.networking.hostName}/secrets/secrets.yaml";

  security.acme = {
    acceptTerms = true;
    defaults.email = "danielrf12@gmail.com";
  };

  # Self-signed Certificate Authority I use to sign other certs
  security.pki.certificateFiles = [ ../certs/ca.crt ];

  environment.etc."wpa_supplicant.conf" = lib.mkIf (config.networking.wireless.enable || config.networking.networkmanager.enable) {
    source = config.sops.secrets."wpa_supplicant.conf".path;
  };
  sops.secrets."wpa_supplicant.conf" = lib.mkIf (config.networking.wireless.enable || config.networking.networkmanager.enable) {
    format = "binary";
    sopsFile = ../secrets/wpa_supplicant.conf;
  };

  nix.settings = {
    trusted-users = [ "danielrf" ];

    # binary-caches = [ "https://daniel.cachix.org/" ];

    # trusted-binary-caches = lib.optional (config.networking.hostName != "bellman") "https://hydra.daniel.fullmer.me";

    trusted-public-keys = [
      "bellman-1:zgaxZSNzvCMGY5sjjgsxEC2uKn3OTW9LWEN0uhjJoO4="
      #"daniel.cachix.org-1:0DFbZ4j3tqoJyqlV8TTd2Vz+CdqKwyuYPTaDPioz4vw="
    ];
  };

  users = {
    groups = {
      danielrf = {};
      vboxsf = {};
    };
    users = {
      danielrf = {
        isNormalUser = true;
        description = "Daniel Fullmer";
        group = "danielrf";
        extraGroups = [
          "users" "wheel" "video" "audio" "networkmanager" "vboxsf" "docker"
          "libvirtd" "systemd-journal" "input"
        ];
        initialPassword = "changeme";
        openssh.authorizedKeys.keys = [ ssh-yubikey ssh-yubikey2 ];
      };
      root.openssh.authorizedKeys.keys = [ ssh-yubikey ssh-yubikey2 ];
    };
  };

  services.cron.mailto = "cgibreak@gmail.com";

# TODO: ssmtp removed in nixpkgs
#  services.ssmtp = lib.mkIf (config.networking.hostName != "bellman") {
#    enable = true;
#    hostName = "bellman";
#    root = "cgibreak@gmail.com";
#  };

  programs.chromium.extensions = [
    "kcgpggonjhmeaejebeoeomdlohicfhce" # Cookie Remover
    "dbepggeogbaibhgnhhndojpepiihcmeb" # vimium
    "ldpochfccmkkmhdbclfhpagapcfdljkj" # Decentraleyes
    "cimiefiiaegbelhefglklhhakcgmhkai" # Plasma integration
    "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
    "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock for youtube
    "dcpihecpambacapedldabdbpakmachpb;https://raw.githubusercontent.com/iamadamdev/bypass-paywalls-chrome/master/src/updates/updates.xml" # Bypass Paywalls: Fite me IRL Google.
    "naepdomgkenhinolocfifgehidddafch" # Browserpass
  ];

  programs.browserpass.enable = config.programs.chromium.enable;

  systemd.user.services = lib.mkIf config.services.xserver.enable {
    #plex-mpv-shim.serviceConfig.ExecStart = "${pkgs.plex-mpv-shim}/bin/plex-mpv-shim";
    jellyfin-mpv-shim.serviceConfig.ExecStart = "${pkgs.jellyfin-mpv-shim}/bin/jellyfin-mpv-shim";
  };
}
