{ stdenv, callPackage, runCommand, writeScript, teensy-loader-cli, hid-listen }:
let 
  firmware = callPackage ./firmware.nix {};
  # Currently running on a Teensy 2.0, ATMEGA32U4
  dactyl-flash = writeScript "dactyl-flash" ''
    #! ${stdenv.shell}
    ${teensy-loader-cli}/bin/teensy-loader-cli --mcu=atmega32u4 ${firmware} $*
  '';
in runCommand "dactyl-keyboard" {} ''
  mkdir -p $out/bin
  cp ${dactyl-flash} $out/bin/dactyl-flash
  ln -s ${hid-listen}/bin/hid_listen $out/bin/dactyl-listen
''
