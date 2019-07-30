{ stdenv, fetchFromGitLab, glib, gdk_pixbuf, vulkan-loader, vulkan-headers, graphene, cairo, meson, ninja, pkgconfig, glslang, gtk-doc, docbook_xsl }:

stdenv.mkDerivation rec {
  pname = "gulkan";
  version = "0.12.1";

  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "xrdesktop";
    repo = "gulkan";
    rev = version;
    sha256 = "1znpq6s7zpb0cpdwh6rnsil6rjidbq4sssdp3x6mz9z8f5ix152b";
  };

  nativeBuildInputs = [ pkgconfig meson ninja glslang gtk-doc docbook_xsl ];
  propagatedBuildInputs = [ glib gdk_pixbuf vulkan-loader vulkan-headers graphene cairo ];
}
