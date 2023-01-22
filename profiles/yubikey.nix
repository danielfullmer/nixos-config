# yubikey.nix: Inteded for hosts I could potentially insert the yubikey into.

{ config, pkgs, lib, ... }:
let
  u2f_key = "danielrf:-lTPHVrWKR1eizhqEq4U5cVF2ozG4o9T6jT1dFvmR1ERuz-lVc6UkOZc1mztVIfZxVuLlDDE2VOb4KJg2wihgg,04b2601eac5bdb1dea7882c10393e0e79c814c4bda2a2b5cb63395173f8c91af0c86e32a39d13c07fa61013985c0b4c81cec08bf72f2e9d456708a08fd4efec141";
  u2f_file = pkgs.writeText "u2f_mapping" u2f_key;
in
{
  services.udev.packages = with pkgs; [ yubikey-personalization ];

  # For smartcards
  services.pcscd.enable = true;

  # Central authorization mapping config from: https://developers.yubico.com/pam-u2f/
  # For single-user: append the output of pamu2fcfg to ~/.config/Yubico/u2f_keys
  security.pam.u2f = {
    enable = true;
    # XXX: Hack to allow me to pass in another parameter to pam module. I should just add origin support in nixpkgs.
    authFile = "${u2f_file} origin=pam://controlnet";
    cue = true;
  };
  security.pam.services."sshd".u2fAuth = false;
  security.pam.services."sudo".u2fAuth = false;

  environment.systemPackages = with pkgs; [
    yubico-piv-tool
    yubikey-personalization
  ] ++ lib.optionals (config.services.xserver.enable) [
    yubioath-flutter
    yubikey-personalization-gui
  ];
}
