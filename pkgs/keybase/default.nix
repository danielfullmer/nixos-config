{ stdenv, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "keybase-${version}";
  version = "1.0.21";

  goPackagePath = "github.com/keybase/client";
  subPackages = [ "go/keybase" "go/kbnm" ];

  dontRenameImports = true;

  src = fetchFromGitHub {
    owner  = "keybase";
    repo   = "client";
    rev    = "v${version}";
    sha256 = "1yms8di621n1b7c1wqkwp2bklz0nbms616wkqx17mqshg8ci4wvc";
  };

  buildFlags = [ "-tags production" ];

  postInstall = ''
    sed -e "s!@@HOST_PATH@@!$bin/bin/kbnm!" $src/go/kbnm/host_json.template > chrome-host.json

    install -D chrome-host.json $bin/etc/chrome-host.json
  '';

  meta = with stdenv.lib; {
    homepage = https://www.keybase.io/;
    description = "The Keybase official command-line utility and service.";
    platforms = platforms.linux;
    maintainers = with maintainers; [ carlsverre ];
  };
}
