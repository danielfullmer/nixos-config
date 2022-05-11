{ buildPythonApplication, fetchFromGitHub, python, setuptools, hidapi }:

buildPythonApplication rec {
  pname = "rivalcfg";
  version = "4.5.0";

  src = fetchFromGitHub {
    owner = "flozz";
    repo = "rivalcfg";
    rev = "v${version}";
    sha256 = "sha256-T2DS4T2bfyNewwqAJRPaBZNS2/amL00Oq2P8GqyeQCE=";
  };

  propagatedBuildInputs = [ setuptools hidapi ];

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

  doCheck = false;
}
