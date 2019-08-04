{ stdenv, fetchFromGitHub, cmake, openvr, SDL2, glew, qt5, vulkan-loader }:

stdenv.mkDerivation rec {
  pname = "openvr-samples";
  version = openvr.version;

  src = openvr.src + /samples;
  patches = [ ./openvr-samples.patch ];

  nativeBuildInputs = [ cmake ];
  buildInputs = [ openvr SDL2 glew qt5.qtbase vulkan-loader ];

  cmakeFlags = [ "-DOPENVR_INCLUDE_DIR=${openvr}/include/openvr" ];

  installPhase = ''
    mkdir -p $out
    cp -rv $cmakeDir/bin $out
  '';
}
