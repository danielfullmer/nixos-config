{ config, pkgs, lib, ... }:
# TODO: Upstream some of this calculation?
  # XXX: The stuff below is a bit hacky. Not at all efficient. No error checking either
  # Integer bit length is tied to underlying platform. Ints are signed as well.
  # So we'll do this byte-at-a-time
with lib;
let
  hexChars = stringToCharacters "0123456789abcdef";
  base32Chars = stringToCharacters "abcdefghijklmnopqrstuvwxyz234567";

  # Return an integer between 0 and 15 representing the hex digit
  fromHexDigit = c:
    (findFirst (x: x.fst == c) c (zipLists hexChars (range 0 (length hexChars - 1)))).snd;

  fromHex = s: foldl (a: b: a*16 + fromHexDigit b) 0 (stringToCharacters (toLower s));

  # Breakup into 2-byte integer chunks. Needs an even length string of hex digits
  bytes = hexstr: map (n: fromHex (substring (2*n) 2 hexstr)) (range 0 (((stringLength hexstr) / 2)-1));

  # Convert an "nwid" as a list of 8 integers into "nwid40" as a list of 5 integers
  nwid40 = lst: [
    (bitXor (elemAt lst 0) (elemAt lst 3))
    (bitXor (elemAt lst 1) (elemAt lst 4))
    (bitXor (elemAt lst 2) (elemAt lst 5))
    (bitXor (elemAt lst 3) (elemAt lst 6))
    (bitXor (elemAt lst 4) (elemAt lst 7))
  ];

  # base32 stuff from zerotier osdep/LinuxEthernetTap.cpp
  # Convert a list of 5 integers to a string containing 8 base32 characters
  toBase32 = lst: concatStrings (map (n: (elemAt base32Chars n)) [
    ((elemAt lst 0) / 8)
    (bitOr ((bitAnd (elemAt lst 0) (fromHex "07")) * 4) ((bitAnd (elemAt lst 1) (fromHex "c0")) / 64))
    ((bitAnd (elemAt lst 1) (fromHex "3e")) / 2)
    (bitOr ((bitAnd (elemAt lst 1) (fromHex "01")) * 16) ((bitAnd (elemAt lst 2) (fromHex "f0")) / 16))
    (bitOr ((bitAnd (elemAt lst 2) (fromHex "0f")) * 2) ((bitAnd (elemAt lst 3) (fromHex "80")) / 128))
    ((bitAnd (elemAt lst 3) (fromHex "7c")) / 4)
    (bitOr ((bitAnd (elemAt lst 3) (fromHex "03")) * 8) ((bitAnd (elemAt lst 4) (fromHex "e0")) / 32))
    (bitAnd (elemAt lst 4) (fromHex "1f"))
  ]);

  # Convert a string like "8056c2e21c36f91e" to the zerotier network interface name like "ztmjfpigyc"
  ifrname = nwid: "zt" + (toBase32 (nwid40 (bytes nwid)));

  machines = import ../machines;
in
{
  services.zerotierone.enable = true;
  services.zerotierone.joinNetworks = [ "8056c2e21c36f91e" ];

  networking.dhcpcd.denyInterfaces = map (s: ifrname s) config.services.zerotierone.joinNetworks;
  networking.firewall.trustedInterfaces = map (s: ifrname s) config.services.zerotierone.joinNetworks;

  systemd.services.zerotierone.serviceConfig.TimeoutSec = 10; # Zerotier sometimes decides not to shutdown quickly

  networking.hosts = mapAttrs' (machine: ip: nameValuePair ip [ machine ]) machines.zerotierIP;

  # If we have incoming traffic to our ZT address from an internet address--this traffic has been forwareded from our external machine.
  # Ensure any traffic responding to this goes out on the right interface.
  networking.iproute2 = {
    enable = true;
    rttablesExtraConfig = ''
      1      zerotier
    '';
  };

  networking.interfaces."ztmjfpigyc".ipv4.routes = mkIf (config.networking.hostName != "gauss") [
    { address = "30.0.0.0"; prefixLength = 24; options = { dev = "ztmjfpigyc"; table = "zerotier"; }; }
    { address = "0.0.0.0"; prefixLength = 0; via = "30.0.0.84"; options = { table = "zerotier"; }; }
  ];

  # TODO: This could also be just from our address
  networking.localCommands = mkIf (config.networking.hostName != "gauss") ''
    ip rule add from 30.0.0.0/24 table zerotier
  '';


  # If using network-interfaces-scripts instead of networkd, need to set it up to depend on zerotier
  systemd.services."network-addresses-ztmjfpigyc".bindsTo = [ "zerotierone.service" ];
  systemd.services."network-addresses-ztmjfpigyc".after = [ "zerotierone.service" ];

  # Override some defaults so the whole network-setup.service doesn't get held up by this interface
  systemd.services."network-addresses-ztmjfpigyc".wantedBy = mkForce [ "network-link-ztmjfpigyc.service" "zerotierone.service" "multi-user.target" ];
  systemd.services."network-addresses-ztmjfpigyc".before = mkForce [ ];
  systemd.services."network-link-ztmjfpigyc".wantedBy = mkForce [ "multi-user.target" ];
  systemd.services."network-link-ztmjfpigyc".before = mkForce [];

  # Kinda gross hack to make upnp work. Holds open an incoming firewall exception from ssdp udp source port (1900) for 3 seconds
  # Couldn't figure out how to make SSDP connection tracking work.
  # As of 2020-01-11. upnp seems to make things worse
#  networking.firewall.extraPackages = [ pkgs.ipset ];
#  networking.firewall.extraCommands = ''
#    ipset -exist create upnp hash:ip,port timeout 3
#    iptables -A OUTPUT -d 239.255.255.250/32 -p udp -m udp --dport 1900 -j SET --add-set upnp src,src --exist
#    iptables -A INPUT -p udp -m set --match-set upnp dst,dst -j ACCEPT
#  '';

  # If debugging is needed, uncomment below:
#  nixpkgs.overlays = [ (self: super: {
#    zerotierone = super.zerotierone.overrideAttrs (attrs: {
#      ZT_DEBUG = true;
#    });
#  }) ];
}
