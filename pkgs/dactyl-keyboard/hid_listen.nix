{ stdenv, fetchzip }:
stdenv.mkDerivation {
  name = "hid_listen-1.1";
  src = fetchzip {
    url = "https://www.pjrc.com/teensy/hid_listen_1.01.zip";
    sha256 = "0sd4dvi39fl4vy880mg531ryks5zglfz5mdyyqr7x6qv056ffx9w";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp hid_listen $out/bin/
  '';
}
