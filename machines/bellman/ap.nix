{ config, pkgs, ... }:
{
  controlnet.ap = {
    enable = true;
    interface = "wlo2";
    subnetNumber = 3;
  };
  # Intel Wifi 6 AX200 with hostapd has an issue where it doesn't try starting
  # an AP since it thinks the channels are not allowed in the regulatory
  # domain. The device seems to manage its own regdb (visible with "iw reg get")
  # Before starting, it is in the "country 00" state with a bunch of channels
  # having IR restrictions, preventing hostapd from trying to bring up the AP.
  # Notably, when running "iw dev wlo2 scan", this would change to "country US"
  # with permissive regulatory restrictions. However, running hostapd
  # immediately after the iw scan was insufficient, as it would go back to
  # "country 00". One ugly workaround was to run networkmanager simultaneously
  # with hostapd, but networkmanager would clobber other settings I wanted to
  # set for the interface, as well as periodically killing the AP. The
  # workaround I settled on was to just have hostapd ignore its own channel
  # checks and try to bring up the AP anyway. This seems to work, and it
  # switches to "country US" when doing so.
  nixpkgs.overlays = [ (self: super: {
    hostapd = super.hostapd.overrideAttrs ({ patches ? [], extraConfig ? "", ... }: {
      patches = patches ++ [ ./hostapd-doitanyway.patch ];
      #extraConfig = extraConfig + ''
      #  CONFIG_IEEE80211AX=y
      #'';
    });
  }) ];
  services.hostapd = {
    hwMode = "a"; # Just means 5ghz
    # See: https://en.wikipedia.org/wiki/List_of_WLAN_channels
    #channel = 0; # ACS. Doesn't work for me.
    channel = 36;
    # https://wiki.gentoo.org/wiki/Hostapd
    # https://medium.com/@renaudcerrato/how-to-build-your-own-wireless-router-from-scratch-part-3-d54eecce157f
    # https://blog.fraggod.net/2017/04/27/wifi-hostapd-configuration-for-80211ac-networks.html
    # https://en.wikipedia.org/wiki/List_of_WLAN_channels#5_GHz_or_5.8_GHz_(802.11a/h/j/n/ac/ax)
    # Set up for 80MHz. Pixel 3 claims to get 780MBps on this
    extraConfig = ''
      wmm_enabled=1

      ieee80211d=1
      ieee80211h=1

      ieee80211n=1
      #require_ht=1
      ht_capab=[HT40+][SHORT-GI-20][SHORT-GI-40][DSSS_CCK-40][MAX-AMSDU-7935][TX-STBC][RX-STBC][LDPC]
      obss_interval=1

      ieee80211ac=1
      #require_vht=1
      vht_capab=[MAX-MDPU-11454][VHT160][RXLDPC][SHORT-GI-80][SHORT-GI-160][TX-STBC-2BY1][SU-BEAMFORMEE][MU-BEAMFORMEE]

      #ieee80211ax=1 #Enabling this strangely slows down my phone to 192Mbps instead of >650-780MBps
      #he_su_beamformee=1
      #he_mu_beamformee=1

      vht_oper_chwidth=1 # 80MHz channel
      vht_oper_centr_freq_seg0_idx=42

      # DFS doesn't seem to work
      #vht_oper_chwidth=2 # 160MHz
      #vht_oper_centr_freq_seg0_idx=50
      # Also try 100 / 114. Would be entirely in empty DFS region.

      # Not supported by this card
      #vht_oper_chwidth=3 # 80+80MHz channel
      #vht_oper_centr_freq_seg0_idx=42
      #vht_oper_centr_freq_seg1_idx=155
    '';
    # (v)ht_capab from comparing output of "iw list" with example hostapd.conf
    # For 8812au
    #vht_capab=[SHORT-GI-80][TX-STBC-2BY1][SU-BEAMFORMEE][HTC-VHT]
  };
}
