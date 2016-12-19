{ stdenv, buildGoPackage, fetchFromGitHub, fetchhg, fetchbzr, fetchsvn }:

buildGoPackage rec {
  name = "rclone-${version}";
  version = "1.34";

  goPackagePath = "github.com/ncw/rclone";

  src = fetchFromGitHub {
    owner = "ncw";
    repo = "rclone";
    rev = "v${version}";
    sha256 = "0c3ckw3jjajb770dsfs0h0ylla95268rrh0cdp31gynmj5jnsx3a";
  };

  goDeps = ./deps.nix;

  meta = {
    description = "Command line program to sync files and directories to and from major cloud storage";
    homepage = "http://rclone.org";
    license = stdenv.lib.licenses.mit;
    maintainers = [ ];
    platforms = stdenv.lib.platforms.all;
  };
}
