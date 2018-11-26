{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation rec {
  name = "dactyl-firmware-${version}";
  version = "0.6.183";

  src = fetchFromGitHub {
    owner = "qmk";
    repo = "qmk_firmware";
    rev = version;
    sha256 = "0mff52kf9zgx2q79zcbp28im5znhymkrkl2f59i2i79cmpl6jjdg";
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
