{ config, lib, pkgs, ... }:

{
  imports = [
    ../../profiles/personal.nix
    ../../profiles/dns.nix
    ../../profiles/zerotier.nix
  ];

  networking.hostName = "viterbi";

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  # This partition is on the sd card.
  # TODO: Once we figure out how to get uboot to boot from the nvme drive,
  # switch to that, instead.
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/ESP";
    fsType = "vfat";
  };

  environment.systemPackages = with pkgs; [ lm_sensors ];

  controlnet.ap = {
    enable = true;
    interface = "wlan1";
    subnetNumber = 8;
    ssid = "controlnet_test_nomap";
  };

  services.hostapd = {
    radios = {
      # TODO: Add 2.4Ghz AP, wlan0
      wlan1 = {
        band = "5g";
        channel = 36;
        countryCode = "US";
        wifi4 = {
          enable = true;
          capabilities = [ "HT40+" "SHORT-GI-20" "SHORT-GI-40" "MAX-AMSDU-7935" "TX-STBC" "RX-STBC" "LDPC" ];
        };
        wifi5 = {
          enable = true;
          operatingChannelWidth = "160";
          capabilities = [ "MAX-MDPU-11454" "VHT160" "RXLDPC" "SHORT-GI-80" "SHORT-GI-160" "TX-STBC-2BY1" "SU-BEAMFORMER" "SU-BEAMFORMEE" "MU-BEAMFORMER" "MU-BEAMFORMEE" ];
        };
        wifi6 = {
          enable = true;
          operatingChannelWidth = "160";
          singleUserBeamformer = true;
          singleUserBeamformee = true;
          multiUserBeamformer = true;
        };
        settings = {
          # 80Mhz width
          #vht_oper_centr_freq_seg0_idx = 42; # TODO: This should be under wifi5 settings
          #he_oper_centr_freq_seg0_idx = 42; # TODO: This should be under wifi6 settings

          # 160 Mhz width
          vht_oper_centr_freq_seg0_idx = 50; # TODO: This should be under wifi5 settings
          he_oper_centr_freq_seg0_idx = 50; # TODO: This should be under wifi6 settings
        };
      };
    };
  };

  networking.useDHCP = false;

  # Bridge everything except the SFP2.5 WAN port, which is internet
  networking.bridges.br0.interfaces = [ "wan" "lan0" "lan1" "lan2" "lan3" ];

  networking.interfaces.br0.ipv4.addresses = [ { address = "192.168.1.1"; prefixLength = 24; } ];
}
