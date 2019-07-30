{ stdenv, fetchFromGitLab, pkgconfig, meson, ninja, glib, gulkan, openvr, gtk3, gtk-doc, docbook_xsl }:

stdenv.mkDerivation rec {
  pname = "gxr";
  version = "0.12.1";

  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "xrdesktop";
    repo = "gxr";
    rev = version;
    sha256 = "09rbvph9j4wbnn7d2grfv0ac5sdjqanw2w85fvs4zw9jicx27k3s";
  };

  nativeBuildInputs = [ pkgconfig meson ninja gtk-doc docbook_xsl ];
  propagatedBuildInputs = [ gulkan openvr gtk3 ];
}
