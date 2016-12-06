{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "neofetch-${version}";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "dylanaraps";
    repo = "neofetch";
    rev = "2.0.1";
    sha256 = "1fxxfg83npyg2idrn9v317wmqk3a24l26fwcs9pbc51nrkmkih01";
  };

  installPhase = ''
    mkdir -p $out
    make PREFIX=$out install
  '';
}
