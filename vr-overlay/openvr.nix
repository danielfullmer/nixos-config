{ stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "openvr";
  version = "1.5.17";

  src = fetchFromGitHub {
    owner = "ValveSoftware";
    repo = "openvr";
    rev = "v${version}";
    sha256 = "11iqhx4vmdaq0kn8ylx5w1lgsyrznv5rp41p7200jsbjmvbcsqg3";
  };
 
  nativeBuildInputs = [ cmake ];
}
