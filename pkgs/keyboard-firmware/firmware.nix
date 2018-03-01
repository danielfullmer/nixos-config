{ stdenv, fetchFromGitHub, avrgcc, avrbinutils, avrlibc }:
let
  avr_incflags = [
    "-isystem ${avrlibc}/avr/include"
    "-B${avrlibc}/avr/lib/avr5"
    "-L${avrlibc}/avr/lib/avr5"
    "-B${avrlibc}/avr/lib/avr35"
    "-L${avrlibc}/avr/lib/avr35"
    "-B${avrlibc}/avr/lib/avr51"
    "-L${avrlibc}/avr/lib/avr51"
  ];
in
stdenv.mkDerivation {
  name = "dactyl-firmware";

  src = fetchFromGitHub {
    owner = "qmk";
    repo = "qmk_firmware";
    rev = "3b801880a084377fc4680fe3fb44e1ef4df0608e";
    sha256 = "1ypmlh32fyzszsj4kh3bpk5abwha1w44kra2ja16sj2dr9plchkw";
  };

  buildInputs = [ avrgcc avrbinutils avrlibc ];

  prePatch = ''
    mkdir -p keyboards/dactyl/keymaps/daniel
    cp -r ${./dactyl}/* keyboards/dactyl
    cp -r ${./keymaps/daniel}/* keyboards/dactyl/keymaps/daniel
    mkdir -p keyboards/ergodox_ez/keymaps/daniel
    cp -r ${./keymaps/daniel}/* keyboards/ergodox_ez/keymaps/daniel
  '';

  buildPhase = ''
    make dactyl:daniel
    make ergodox_ez:daniel
  '';

  installPhase = ''
    mkdir -p $out
    cp .build/dactyl_daniel.hex $out/
    cp .build/ergodox_ez_daniel.hex $out/
  '';

  CFLAGS = avr_incflags;
  ASFLAGS = avr_incflags;
}
