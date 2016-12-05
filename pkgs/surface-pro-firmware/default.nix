{ stdenv }:

stdenv.mkDerivation {
  name = "surface-pro-firmware";
  src = ./firmware;
  installPhase = ''
    mkdir -p $out/lib/firmware/
    cp -r * $out/lib/firmware/
  '';
}
