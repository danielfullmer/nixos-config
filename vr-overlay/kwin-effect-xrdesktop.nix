{ stdenv, fetchFromGitLab, cmake, extra-cmake-modules, xrdesktop, graphene, libinputsynth, kwin, epoxy }:

stdenv.mkDerivation rec {
  pname = "kwin-effect-xrdesktop";
  version = "0.12.1";

  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "xrdesktop";
    repo = "kwin-effect-xrdesktop";
    rev = version;
    sha256 = "1gd6jz0b4q6aila1cddm98gg0mrjzcnqr348qgf5k72p2dx3cy36";
  };

  nativeBuildInputs = [ cmake extra-cmake-modules ];
  buildInputs = [ xrdesktop graphene libinputsynth kwin epoxy ];
}
