{ stdenv, fetchFromGitHub, perl }:

stdenv.mkDerivation {
  name = "xcompose-20170831";

  src = fetchFromGitHub {
    owner = "kragen";
    repo = "xcompose";
    rev = "cb2c1de020291bef82e69bd5bd19da40401ada03";
    sha256 = "11gmrkbgm8vvvvy527zm6zn1z6hwr92v5bs8xzifg55j48151839";
  };

  nativeBuildInputs = [ perl ];

  postPatch = ''
    substituteInPlace emojitrans2.pl --replace "/usr/bin/perl" "${perl}/bin/perl"
  '';

  installPhase = ''
    mkdir -p $out
    cp dotXCompose frakturcompose emoji.compose modletters.compose parens.compose $out
  '';
}
