{ config, pkgs, ... }:
let
  #interface = "wlp71s0f3u4";
  interface = "wlo2";
in
{
#  networking.bridges.br0.interfaces = [ interface "enp68s0" ];
#  networking.interfaces."${interface}".proxyARP = true;
#  networking.interfaces.enp68s0.proxyARP = true;
  services.hostapd = {
    enable = true;
    inherit interface;
    ssid = "controlnet2_nomap";
    hwMode = "a"; # Just means 5ghz
    channel = 36;
    # https://wiki.gentoo.org/wiki/Hostapd
    # https://medium.com/@renaudcerrato/how-to-build-your-own-wireless-router-from-scratch-part-3-d54eecce157f
    # https://blog.fraggod.net/2017/04/27/wifi-hostapd-configuration-for-80211ac-networks.html
    # Set up for 80MHz. Pixel 3 claims to get 780MBps on this
    extraConfig = ''
      ieee80211n=1
      ieee80211ac=1
      #require_ht=1
      #require_vht=1
      wmm_enabled=1
      rsn_pairwise=CCMP
      wpa_key_mgmt=WPA-PSK WPA-PSK-SHA256
      country_code=US
      ht_capab=[HT40+][SHORT-GI-20][SHORT-GI-40][DSSS_CCK-40][MAX-AMSDU-7935][TX-STBC][RX-STBC][LDPC]
      vht_oper_chwidth=1
      vht_oper_centr_freq_seg0_idx=42


      # Intel wifi 6 AX200
      vht_capab=[RXLDPC][SHORT-GI-80][SHORT-GI-160][TX-STBC-2BY1][SU-BEAMFORMEE][MU-BEAMFORMEE]
    '';
    # (v)ht_capab from comparing output of "iw list" with example hostapd.conf
    # For 8812au
    #vht_capab=[SHORT-GI-80][TX-STBC-2BY1][SU-BEAMFORMEE][HTC-VHT]
    wpaPassphrase = "verysecure2";
  };
#  services.dnsmasq = {
#    enable = true;
#    resolveLocalQueries = false;
#    servers = [ "127.0.0.1" ]; # Use local unbound server
#    extraConfig = ''
#      interface=${interface}
#
#      dhcp-range=192.168.4.2,192.168.4.254
#    '';
#  };
  networking.interfaces."${interface}".ipv4.addresses = [ { address = "192.168.4.1"; prefixLength = 24; }];
  networking.firewall.trustedInterfaces = [ interface ];
  networking.nat.enable = true;
  networking.nat.externalInterface = "enp68s0";
  networking.nat.internalInterfaces = [ interface ];

  environment.systemPackages = with pkgs; [ iw wirelesstools ];
}
