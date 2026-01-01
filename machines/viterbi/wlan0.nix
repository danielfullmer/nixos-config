{ config, lib, pkgs, ... }:

{
  # This is configuration from modules/ap.nix that are being duplicated for the wlan0 2.4ghz network
  services.hostapd.radios.wlan0 = {
    band = "2g";
    channel = 11;
    countryCode = "US";

    networks.wlan0 = {
      ssid = "controlnet26ghz_nomap";
      authentication = {
        mode = "wpa2-sha256";
        #mode = "wpa3-sae-transition"; # TODO: Switch to wpa3-sae entirely, remove WPA-PSK. 8sleep doesn't support WPA3
        wpaPskFile = config.sops.secrets.wpa_psk_file.path;
        saePasswordsFile = config.sops.secrets.sae_passwords.path;
      };
    };
  };
  networking.interfaces."wlan0".ipv4.addresses = [ { address = "192.168.4.1"; prefixLength = 24; }];
  networking.firewall.interfaces."wlan0" = {
    allowedUDPPorts = [ 53 67 ]; # DNS and DHCP
  };
  services.dnsmasq.settings = {
    interface = "wlan0";
    dhcp-range = "interface:wlan0,192.168.4.1,192.168.4.254";
  };

  networking.nat.internalInterfaces = [ "wlan0" ];
}
