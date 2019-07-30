{ stdenv, fetchFromGitLab, pkgconfig, meson, ninja, glib, xdotool, libX11, libXtst, libXi, libXext }:

stdenv.mkDerivation rec {
  pname = "libinputsynth";
  version = "0.12.1";

  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "xrdesktop";
    repo = "libinputsynth";
    rev = version;
    sha256 = "0m5ksg26xlvbj2dxwl2cpnqi5whghp4w0g9sjc1zbnid6ms2hf6k";
  };

  postPatch = ''
    substituteInPlace meson.build --replace "'xdo', dirs : ['/usr/lib']" "'xdo', dirs : ['${xdotool}/lib']"
  '';

  nativeBuildInputs = [ pkgconfig meson ninja ];
  buildInputs = [ xdotool libX11 libXtst libXi libXext ]; # mutter stuff?
  propagatedBuildInputs = [ glib ];
}
