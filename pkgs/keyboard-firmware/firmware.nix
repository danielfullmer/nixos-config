{ stdenv, writeText, fetchFromGitHub, keymap }:
let
  keymap-config = writeText "keymap_config.h" keymap;
in
stdenv.mkDerivation rec {
  name = "dactyl-firmware-${version}";
  version = "0.6.328";

  src = fetchFromGitHub {
    owner = "qmk";
    repo = "qmk_firmware";
    rev = version;
    sha256 = "080hhjxxbxdf3wa9xkhsgwjsljaix1lg5rqrmxkpyvrvc6dl82mx";
  };

  prePatch = ''
    mkdir -p keyboards/dactyl/keymaps/daniel
    cp -r ${./dactyl}/* keyboards/dactyl
    cp -r ${./keymaps/daniel}/* keyboards/dactyl/keymaps/daniel
    cp ${keymap-config} keyboards/dactyl/keymaps/daniel/keymap_config.h
    mkdir -p keyboards/ergodox_ez/keymaps/daniel
    cp -r ${./keymaps/daniel}/* keyboards/ergodox_ez/keymaps/daniel
    cp ${keymap-config} keyboards/ergodox_ez/keymaps/daniel/keymap_config.h
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
