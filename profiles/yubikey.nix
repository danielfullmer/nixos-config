{ config, pkgs, lib, ... }:
{
  #services.udev.packages = [ pkgs.libu2f-host ];
  services.udev.extraRules = ''
    # From https://github.com/Yubico/libu2f-host/blob/master/70-u2f.rules
    ACTION!="add|change", GOTO="u2f_end"

    # Yubico YubiKey
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0113|0114|0115|0116|0120|0402|0403|0406|0407|0410", TAG+="uaccess"

    LABEL="u2f_end"
  '';

  # For smartcards
  services.pcscd.enable = true;

  # Use gpg-agent instead of system-wide ssh-agent
  programs.ssh.startAgent = false;
  programs.gnupg = {
    agent.enable = true;
    agent.enableSSHSupport = true;
  };

  # To use, append the output of pamu2fcfg to ~/.config/Yubico/u2f_keys
  security.pam.enableU2F = true;

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

  #  services.xserver.desktopManager.extraSessionCommands = ''
  #    (yubioath-gui -t) &
  #    (keybase-gui) &
  #  '';

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
    # XXX: Can't just do [[ ! -d /keybase ]] since root can't even stat() this dir if mounted
    if ls -f / | grep -q keybase; then false;
    else
      mkdir /keybase
      chown danielrf:danielrf /keybase
    fi
  '';

  environment.etc."chromium/native-messaging-hosts/io.keybase.kbnm.json".source = "${pkgs.keybase}/etc/chrome-host.json";
  environment.etc."opt/chrome/native-messaging-hosts/io.keybase.kbnm.json".source = "${pkgs.keybase}/etc/chrome-host.json";
}
