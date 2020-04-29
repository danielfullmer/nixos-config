{ config, pkgs, lib, ... }:

with lib;
let
  cfg = config.controlnet.ap;
in
{
  options = {
    controlnet.ap = {
      enable = mkEnableOption "access point";

      interface = mkOption {
        default = "wlan0";
        type = types.str;
      };

      subnetNumber = mkOption {
        type = types.int;
      };
    };
  };

  config = mkIf cfg.enable {
    services.hostapd = {
      enable = true;
      ssid = "controlnet_nomap";
      inherit (cfg) interface;
      # For each device, they are going to have to add their own hwMode, extraConfig for ht_capab, what ieee modes are supported etc.
      extraConfig = ''
        country_code=US
        rsn_pairwise=CCMP
        wpa_key_mgmt=WPA-PSK
      '';
      wpaPassphrase = "verysecure";
    };

    networking.interfaces."${cfg.interface}".ipv4.addresses = [ { address = "192.168.${toString cfg.subnetNumber}.1"; prefixLength = 24; }];
    networking.firewall.interfaces."${cfg.interface}" = {
      allowedUDPPorts = [ 53 67 ]; # DNS and DHCP
    };
    networking.nat.enable = true;
    networking.nat.internalInterfaces = [ cfg.interface ];

    services.dnsmasq = {
      enable = true;
      resolveLocalQueries = false;
      servers = [ "127.0.0.1" ]; # Use local unbound server
      extraConfig = ''
        listen-address=192.168.${toString cfg.subnetNumber}.1
        bind-interfaces # Bind to the specific interface, not 0.0.0.0

        dhcp-range=192.168.${toString cfg.subnetNumber}.2,192.168.${toString cfg.subnetNumber}.254
      '';
    };

    environment.systemPackages = with pkgs; [ wirelesstools iw ];
    services.udev.packages = with pkgs; [ crda ];
  };
}
