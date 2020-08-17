{ lib, buildGoPackage, fetchFromGitHub }: 

buildGoPackage rec {
  pname = "systemd-exporter";
  version = "0.4.0";

  goPackagePath = "github.com/povilasv/systemd_exporter";
  goDeps = ./deps.nix;

  src = fetchFromGitHub {
    owner = "povilasv";
    repo = "systemd_exporter";
    rev = "v${version}";
    sha256 = "11sz4hv390f1wwa208lg2hkb7nhkaj4scfqhngyk77f5rhfx2dr4";
  };

  meta = with lib; {
    homepage = "https://github.com/povilasv/systemd_exporter";
    license = [ licenses.apl2 ];
    description = "Exporter for systemd unit metrics";
  };
}
