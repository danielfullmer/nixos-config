rec {
  vhostPublic = {
    listen = [
      { addr = "0.0.0.0"; port = 80; }
      { addr = "0.0.0.0"; port = 443; ssl = true; }
      { addr = "0.0.0.0"; port = 9443; ssl = true; extraParameters = [ "proxy_protocol" ]; }
    ];
    forceSSL = true;
    enableACME = true;
    extraConfig = ''
      set_real_ip_from 30.0.0.0/24;
      real_ip_header proxy_protocol;
    '';
  };
  # Allow localhost, zerotier, and wireguard hosts
  denyInternet = ''
    allow 127.0.0.1;
    allow ::1;
    allow 30.0.0.0/24;
    allow 10.200.0.0/24;
    deny all;
  '';
  vhostPrivate = vhostPublic // { extraConfig = vhostPublic.extraConfig + denyInternet; };
}
