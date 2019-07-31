{ stdenv, fetchFromGitLab, glib, gdk_pixbuf, vulkan-loader, vulkan-headers, graphene, cairo, meson, ninja, pkgconfig, glslang, gtk-doc, docbook_xsl }:

stdenv.mkDerivation rec {
  pname = "gnome-shell-extension-xrdesktop";
  version = "0.12.1";

  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "xrdesktop";
    repo = "gnome-shell-extension-xrdesktop";
    rev = version;
    sha256 = "0b0qzpqqrdhi57xwwj0g6bjbqqiar76ka40f2y4bhbrx40mva9nl";
  };

  nativeBuildInputs = [ pkgconfig meson ninja ];
}
