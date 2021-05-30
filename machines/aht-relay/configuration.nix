{ config, pkgs, lib, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./networking.nix # generated at runtime by nixos-infect
    ../../profiles/base.nix
  ];

  boot.cleanTmpDir = true;
  networking.hostName = "aht-relay";
  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;

  services.zerotierone.enable = true;
  services.zerotierone.joinNetworks = [ "12ac4a1e71fd3ca2" ];

  # Logs into pritunl VPN via openvpn interface
  services.openvpn.servers.twosix = {
    config = ''
      config ${config.sops.secrets.twosix-pritunl-ovpn.path}
    '';
  };

  # Format for this file is:
  # <username>
  # <PIN><OTP>
  systemd.services.openvpn-twosix.serviceConfig.Restart = lib.mkForce "no";
  systemd.services.openvpn-twosix.preStart = ''
    echo daniel.fullmer > /run/keys/twosix-pritunl-userpass
    chmod 600 /run/keys/twosix-pritunl-userpass
    echo -n "$(cat ${config.sops.secrets.twosix-pritunl-pin.path})" >> /run/keys/twosix-pritunl-userpass
    xargs -a ${config.sops.secrets.twosix-pritunl-otp.path} ${pkgs.oathToolkit}/bin/oathtool --totp -b >> /run/keys/twosix-pritunl-userpass
  '';

  sops.secrets.twosix-pritunl-pin = {};
  sops.secrets.twosix-pritunl-otp = {};
  sops.secrets.twosix-pritunl-ovpn = {};

  #networking.nameservers = lib.mkBefore [ "10.80.4.5" ];

  networking.nameservers = lib.mkBefore [ "127.0.0.1" ];
  services.unbound = {
    enable = true;
    settings = {
      forward-zone = [ {
        name = "\"twosix.local.\"";
        forward-addr = "10.80.4.5";
      } ];
      server = {
        interface = [ "127.0.0.1" "::1" ];
        #verbosity: 2

        # Disable DNSSEC, not working for .local
        module-config = "iterator";
      };
    };
  };

  services.privoxy = {
    enable = true;
    settings.listen-address = "0.0.0.0:8118";
  };
  networking.firewall.interfaces."ztbto3oiwt".allowedTCPPorts = [ 8118 ]; # Only allow access over zerotier
}
