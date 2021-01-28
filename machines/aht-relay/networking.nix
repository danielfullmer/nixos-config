{ lib, ... }: {
  # This file was populated at runtime with the networking
  # details gathered from the active system.
  networking = {
    nameservers = [ "8.8.8.8"
 ];
    defaultGateway = "104.131.64.1";
    defaultGateway6 = "";
    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkForce false;
    interfaces = {
      eth0 = {
        ipv4.addresses = [
          { address="104.131.122.153"; prefixLength=18; }
{ address="10.17.0.6"; prefixLength=16; }
        ];
        ipv6.addresses = [
          { address="fe80::ac2c:44ff:fea1:2f06"; prefixLength=64; }
        ];
        ipv4.routes = [ { address = "104.131.64.1"; prefixLength = 32; } ];
        ipv6.routes = [ { address = ""; prefixLength = 32; } ];
      };
      
    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="ae:2c:44:a1:2f:06", NAME="eth0"
    ATTR{address}=="52:8f:fe:85:6b:e1", NAME="eth1"
  '';
}
