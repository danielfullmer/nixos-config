{ stdenv, fetchFromGitHub }:
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
