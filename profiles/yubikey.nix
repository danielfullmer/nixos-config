{ config, pkgs, lib, ... }:
{
  #services.udev.packages = [ pkgs.libu2f-host ];
  services.udev.extraRules = ''
    # From https://github.com/Yubico/libu2f-host/blob/master/70-u2f.rules
    ACTION!="add|change", GOTO="u2f_end"

    # Yubico YubiKey
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0113|0114|0115|0116|0120|0402|0403|0406|0407|0410", GROUP="wheel", MODE="0660"
    # TODO: Try to replace group/mode with just TAG+="uaccess"

    LABEL="u2f_end"
  '';

  # For smartcards
  services.pcscd.enable = true;

  # Use gpg-agent instead of system-wide ssh-agent
  programs.ssh.startAgent = false;
  environment.extraInit = ''
    export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
    gpg-connect-agent updatestartuptty /bye >/dev/null 2>/dev/null
  '';

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
  ]);

  services.xserver.desktopManager.extraSessionCommands = "(yubioath-gui -t) &";
}
