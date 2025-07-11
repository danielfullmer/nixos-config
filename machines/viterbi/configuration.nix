{ config, lib, pkgs, ... }:


{
  imports = [
    ../../profiles/personal.nix
    ../../profiles/dns.nix
    ../../profiles/zerotier.nix

    ../../profiles/cameras.nix
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

  environment.systemPackages = with pkgs; [ lm_sensors ethtool ];

  controlnet.ap = {
    enable = true;
    interface = "wlan1";
    subnetNumber = 3;
    ssid = "controlnet_nomap";
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

  # From left to right on front of BPI-R3:
  # eth1 lan4  wan  lan0 lan1 lan2 lan3
  #
  # Internal connections:
  # eth1 is 2500BaseT SFP1 connected directly to CPU (MT7968A).
  # lan4 is 2500BaseT SFP2 connected to internal switch.
  # wan and lan0 - lan3 are all 1000BaseT connected to internal switch (MT7531AE)
  #
  # External connections:
  # eth1 connected to upstream internet provider 1
  # lan4 connected directly to bellman
  # wan connected to internet provider 2
  # lan0 connected to garage opener
  # lan1 connected to wrench/downstairs
  # lan2 connected to printer
  # lan3 connected to cameras

  networking.useDHCP = false;
  services.openssh.openFirewall = false;

  # Connected to Cable modem (Internet)
  networking.interfaces.eth1 = {
    useDHCP = true;
    macAddress = "b4:2e:99:a7:0b:e8";
  };
  networking.firewall.interfaces.eth1.allowedUDPPorts = [ 68 ]; # DHCP Client

  # Connected to Fiber ONT (Internet)
  networking.interfaces.wan.useDHCP = true;
  networking.firewall.interfaces.wan.allowedUDPPorts = [ 68 ]; # DHCP Client

  # Bridge lan0 - lan4
  networking.bridges.br0.interfaces = [ "lan0" "lan1" "lan2" "lan4" ];
  networking.interfaces.br0.ipv4.addresses = [ { address = "192.168.1.1"; prefixLength = 24; } ];
  networking.firewall.interfaces.br0.allowedTCPPorts = [ 22 ]; # SSH
  networking.firewall.interfaces.br0.allowedUDPPorts = [ 53 67 ]; # DNS, and DHCP
  services.dnsmasq.settings = {
    interface = "br0";
    dhcp-range = "interface:br0,192.168.1.100,192.168.1.199";
  };

  networking.firewall.interfaces.wlan1.allowedTCPPorts = [ 22 ];

  networking.nat.externalInterface = "wan";
  networking.nat.internalInterfaces = [ "br0" ];

  # TODO: Multihomed routing. Two Internet connections.
  # Naively, we just get two default routes, one with a higher metric. This works fine for outgoing packets if you specify the interface.

  # Added to /etc/iproute2
  # ip route add table cable default via 107.139.226.1 dev wan
  # iptables -t mangle -I PREROUTING 1 -s 107.139.226.229 -j MARK --set-mark 2 # 2 is cable
  # iptables -t mangle -I OUTPUT 1 -s 107.139.226.229 -j MARK --set-mark 2 # 2 is cable
  # ip rule add fwmark 2 table cable
  # iptables -t mangle -I nixos-fw-rpfilter 1 -i wan -j RETURN
  # ip mptcp endpoint add 104.34.221.56 dev eth1 subflow
  # ip mptcp endpoint add 107.139.226.229 dev wan subflow

  # Ran this on gauss:
  # ip mptcp endpoint add 167.71.187.97 dev ens3 signal
  # ip mptcp limits set subflows 2  # For some reason its default is 0
}
