{ stdenv, fetchFromGitHub, autoreconfHook, pkgconfig
, libdrm, libpng, wayland, libxcb, mesa, vulkan-loader
}:

stdenv.mkDerivation {
  name = "vkcube-2017-01-09";

  src = fetchFromGitHub {
    owner = "krh";
    repo = "vkcube";
    rev = "80c0d047c257f486d054f28b0b381abef3327069";
    sha256 = "1638wzi5ay0z1h3gskld5xivq3ijg1shfsdrhgwgl9gh8iji66cm";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp vkcube $out/bin
  '';

  nativeBuildInputs = [ autoreconfHook pkgconfig ];
  buildInputs = [ libdrm libpng wayland libxcb mesa vulkan-loader ];
}
