{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation rec {
  name = "dactyl-firmware-${version}";
  version = "0.6.31";

  src = fetchFromGitHub {
    owner = "qmk";
    repo = "qmk_firmware";
    rev = version;
    sha256 = "1y5ljlf9snb2cbbgl24ngq7anfqfnp454n3ng39cvh6pdl0j5z93";
  };

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
}
