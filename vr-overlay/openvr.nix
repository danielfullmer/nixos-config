{ stdenv, fetchFromGitHub, cmake, SDL2, vulkan-loader }:

stdenv.mkDerivation rec {
  pname = "openvr";
  version = "1.6.10";

  src = fetchFromGitHub {
    owner = "ValveSoftware";
    repo = "openvr";
    rev = "v${version}";
    sha256 = "1pxjwpz8qcgdjqzd2ixmlngnsyw6cyjd6mqjjaw2jsxpkms1h1a4";
  };

  nativeBuildInputs = [ cmake ];

  # Steam's provided vrclient.so uses these libs, so let's link them in now so it can properly dlopen() vrclient.so
  NIX_LDFLAGS = "-L${SDL2}/lib -lSDL2 -L${vulkan-loader}/lib -lvulkan";

  cmakeFlags = [ "-DBUILD_SHARED=1" ];
}
