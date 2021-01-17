{ buildPythonApplication, fetchFromGitHub, python, hidapi }:

buildPythonApplication rec {
  pname = "rivalcfg";
  version = "4.2.0";

  src = fetchFromGitHub {
    owner = "flozz";
    repo = "rivalcfg";
    rev = "v${version}";
    sha256 = "1m0nk6zvv7mkgbyffm7nl44a7f09hxw5azwkxrrabf97dbsnr0vd";
  };

  propagatedBuildInputs = [ hidapi ];

  postBuild = ''
    ${python.interpreter} <<EOF
    import sys
    import rivalcfg.udev
    rivalcfg.udev.write_rules_file(path='99-steelseries-rival.rules')
    EOF
  '';

  postInstall = ''
    mkdir -p $out/lib/udev/rules.d
    mv 99-steelseries-rival.rules $out/lib/udev/rules.d
  '';
}
