{ stdenv, lib, fetchFromGitHub, cmake, jetson-ffmpeg-src, nvidia-jetpack }:

let
  inherit (nvidia-jetpack) l4t-multimedia;
in
stdenv.mkDerivation {
  pname = "libnvmpi";
  version = "unstable-2025-08-25";

  src = jetson-ffmpeg-src;

  buildInputs = [ l4t-multimedia ];
  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    (lib.cmakeFeature "JETSON_MULTIMEDIA_API_DIR" "${l4t-multimedia}")
    (lib.cmakeFeature "JETSON_MULTIMEDIA_LIB_DIR" "${l4t-multimedia}/lib")
  ];
}
