{ pkgsCross, runCommand, writeScript, teensy-loader-cli, hid-listen }:
let 
  # Currently running on a Teensy 2.0, ATMEGA32U4
  firmware = pkgsCross.avr.callPackage ./firmware.nix {};

  keyboard-flash = name: writeScript "${name}-flash" ''
    #!/bin/sh
    ${teensy-loader-cli}/bin/teensy-loader-cli --mcu=atmega32u4 ${firmware}/${name}_daniel.hex $*
  '';
  dactyl-flash = keyboard-flash "dactyl";
  ergodox-flash = keyboard-flash "ergodox_ez";
in runCommand "dactyl-keyboard" {} ''
  mkdir -p $out/bin
  cp ${dactyl-flash} $out/bin/dactyl-flash
  cp ${ergodox-flash} $out/bin/ergodox-flash
  ln -s ${hid-listen}/bin/hid_listen $out/bin/kb-listen
''
