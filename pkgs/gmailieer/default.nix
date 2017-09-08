{ stdenv, fetchFromGitHub, python3Packages}:

python3Packages.buildPythonApplication rec {
  name = "gmailieer-${version}";
  version = "0.3";

  src = fetchFromGitHub {
    owner = "gauteh";
    repo = "gmailieer";
    rev = "v${version}";
    sha256 = "1app783gf0p9p196nqsgbyl6s1bp304dfav86fqiq86h1scld787";
  };

  propagatedBuildInputs = with python3Packages; [ tqdm google_api_python_client oauth2client notmuch ];
}
