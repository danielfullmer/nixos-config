# yubikey.nix: Inteded for hosts I could potentially insert the yubikey into.

{ config, pkgs, lib, ... }:
let
  u2f_key = "danielrf:-lTPHVrWKR1eizhqEq4U5cVF2ozG4o9T6jT1dFvmR1ERuz-lVc6UkOZc1mztVIfZxVuLlDDE2VOb4KJg2wihgg,04b2601eac5bdb1dea7882c10393e0e79c814c4bda2a2b5cb63395173f8c91af0c86e32a39d13c07fa61013985c0b4c81cec08bf72f2e9d456708a08fd4efec141";
  u2f_file = pkgs.writeText "u2f_mapping" u2f_key;
in
{
  hardware.u2f.enable = true;
  services.udev.packages = with pkgs; [ yubikey-personalization ];

  # For smartcards
  services.pcscd.enable = true;

  # Use gpg-agent instead of system-wide ssh-agent
  programs.ssh.startAgent = false;
  programs.gnupg = {
    agent.enable = true;
    agent.enableSSHSupport = true;
    agent.enableExtraSocket = true;
    agent.enableBrowserSocket = true;
    dirmngr.enable = true;
  };

  # Central authorization mapping config from: https://developers.yubico.com/pam-u2f/
  # For single-user: append the output of pamu2fcfg to ~/.config/Yubico/u2f_keys
  security.pam.u2f = {
    enable = true;
    # XXX: Hack to allow me to pass in another parameter to pam module. I should just add origin support in nixpkgs.
    authFile = "${u2f_file} origin=pam://${config.networking.domain}";
    cue = true;
  };
  security.pam.services."sshd".u2fAuth = false;

  environment.systemPackages = (with pkgs; [
    yubico-piv-tool
    yubikey-personalization

    gnupg
    pass

    keybase
    kbfs
  ] ++ lib.optionals (config.services.xserver.enable) [
    yubioath-desktop
    yubikey-personalization-gui
    keybase-gui
  ]);

  systemd.services.gpg-key-import = {
    description = "Import gpg keys";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "danielrf";
      Group = "danielrf";
    };
    script = ''
      ${lib.getBin pkgs.gnupg}/bin/gpg --import ${./yubikey.asc} ${./offlinekey.asc}
      ${lib.getBin pkgs.gnupg}/bin/gpg --import-ownertrust << EOF
      FA0ED54AE0DBF4CDC4B4FEADD1481BC2EF6B0CB0:6:
      7242A6FEF237A429E981576F6EDF0AEEA2D9FA5D:6:
      EOF
    '';
    # TODO: Maybe create a udev rule to run "gpg --card-status" when yubikey plugged in first time
  };

  services.keybase.enable = true;
  services.kbfs.enable = true;
  services.kbfs.mountPoint = "/keybase";

  # TODO: See https://github.com/keybase/client/issues/3508
  # systemd.user.sockets.keybase = {
  #   description = "Keybase socket";
  #   after = [ "network.target" ];
  #   wantedBy = [ "sockets.target" ];
  #   socketConfig.ListenStream = "%t/keybase/keybased.sock";
  # };

  systemd.user.services.keybase = {
    after = [ "network.target" ];
    wantedBy = [ "default.target" ]; # TODO: Remove this when socket-activation works
  };

  systemd.user.services.kbfs = {
    after = [ "keybase.target" ];
    wantedBy = [ "default.target" ];
  };

  # TODO: Remove this hack when keybase becomes multi-user
  system.activationScripts.keybase = lib.stringAfter [ "users" "groups" ] ''
    mkdir -p /keybase 2>/dev/null
    chown -f danielrf:danielrf /keybase
  '';
}
