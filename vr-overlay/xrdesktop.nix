{ stdenv, fetchFromGitLab, pkgconfig, meson, ninja, gxr, gtk-doc, docbook_xsl, glslang, python3 }:

stdenv.mkDerivation rec {
  pname = "xrdesktop";
  version = "0.12.1";

  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "xrdesktop";
    repo = "xrdesktop";
    rev = version;
    sha256 = "0say21b4j25k3cp0wcdzx6blrkv4064lyirbbhrd2wv15gd05x1x";
  };

  postPatch = ''
    chmod +x res/meson_post_install.py
    patchShebangs res/meson_post_install.py
  '';

  nativeBuildInputs = [ pkgconfig meson ninja glslang gtk-doc docbook_xsl python3 ];
  propagatedBuildInputs = [ gxr ];
}
