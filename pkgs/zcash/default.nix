{ stdenv, callPackage, fetchurl, fetchFromGitHub, pkgconfig, autoreconfHook,
openssl, zlib, miniupnpc, gmp, gmpxx, procps, libsodium,
utillinux, protobuf, qrencode, libevent, openssl_1_1_0, cryptopp }:

let
db62 = callPackage <nixpkgs/pkgs/development/libraries/db/generic.nix> ({
  version = "6.2.23";
  sha256 = "1isxx4jfmnh913jzhp8hhfngbk6dsg46f4kjpvvc56maj64jqqa7";
  license = stdenv.lib.licenses.agpl3;
  branch = "6.2";
});
boost162 = callPackage <nixpkgs/pkgs/development/libraries/boost/generic.nix> ({
  version = "1.62.0";
  src = fetchurl {
    url = "mirror://sourceforge/boost/boost_1_62_0.tar.bz2";
    sha256 = "181czc5bj7k1v0dblgrkl2f2fa4s654fp30x14289jamc47npj9n";
  };
});
libsnark = stdenv.mkDerivation rec {
  name = "libsnark";

  src = fetchFromGitHub {
    owner = "zcash";
    repo = "libsnark";
    rev = "2e6314a9f7efcd9af1c77669d7d9a229df86a777";
    sha256 = "0k4jhgc251d3ymga0sc1wiqhgklayr5d94n15jlb3n2lnqra07d5";
  };

  buildInputs = [ gmp gmpxx openssl procps boost162 zlib libsodium ];

  # These instructions came from zcash/depends/packages/libsnark.mk
  buildPhase = "
  CXXFLAGS=\"-fPIC -DBINARY_OUTPUT -DNO_PT_COMPRESSION=1\" make lib CURVE=ALT_BN128 MULTICORE=1 NO_PROCPS=1 NO_GTEST=1 NO_DOCS=1 STATIC=1 NO_SUPERCOP=1 FEATUREFLAGS=-DMONTGOMERY_OUTPUT";

  installPhase = "make install PREFIX=\"$out\" STATIC=1 CURVE=ALT_BN128 NO_SUPERCOP=1";
};
in
stdenv.mkDerivation rec {
  # See the bitcoin derivation in nixpkgs

  name = "zcash-${version}";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "zcash";
    repo = "zcash";
    rev = "26fb4db53bc437617752ac1818efd34eec466485";
    sha256 = "019vcyanmwhd4sr4wkbygrnvpzkb8xv3cin8sm76bq8bdfq9asgi";
  };

  patches = [ ./0001-Boost-mt-extension-is-deprecated.patch ];

  buildInputs = [ pkgconfig autoreconfHook openssl_1_1_0 db62 boost162 zlib
                  miniupnpc protobuf libevent utillinux
                  gmp gmpxx cryptopp libsnark libsodium ];

  configureFlags = [ "--with-boost-libdir=${boost162.out}/lib"
                     "--with-gui=no"
                     "--disable-tests"
                     "CXXFLAGS=-O0"
                     "CPPFLAGS=-I${libsnark}/include" ];
}
