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
in
{
  services.zerotierone.enable = true;
  services.zerotierone.joinNetworks = [ "8056c2e21c36f91e" ];

  networking.dhcpcd.denyInterfaces = map (s: ifrname s) config.services.zerotierone.joinNetworks;
  networking.firewall.trustedInterfaces = map (s: ifrname s) config.services.zerotierone.joinNetworks;

  systemd.services.zerotierone.serviceConfig.TimeoutSec = 10; # Zerotier sometimes decides not to shutdown quickly

  networking.hosts = let
    machines = import ../machines;
  in mapAttrs' (machine: ip: nameValuePair ip [ machine ]) machines.zerotierIP;
}
