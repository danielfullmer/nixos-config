{ stdenv, fetchFromGitHub, cmake }:

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
}
