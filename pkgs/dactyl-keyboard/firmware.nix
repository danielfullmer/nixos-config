{ stdenv, fetchFromGitHub, avrgcclibc }:
stdenv.mkDerivation {
  name = "tmk-keyboard-firmware";

  src = fetchFromGitHub {
    owner = "danielfullmer";
    repo = "tmk_keyboard";
    rev = "99e34040bf4862380a54f49650da489aac6b1c3e";
    sha256 = "0j3k6nq2kbpb4fwlv1agxzp0y8qki5sg9yl6jf108x1a3a7bhnz8";
  };

  buildInputs = [ avrgcclibc ];

  buildPhase = ''
    cd keyboard/dactyl
    make -f Makefile.pjrc daniel
  '';

  installPhase = ''
    cp dactyl_pjrc.hex $out
  '';
}
