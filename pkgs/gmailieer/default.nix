{ stdenv, fetchFromGitHub, python3Packages}:

python3Packages.buildPythonApplication rec {
  name = "gmailieer-${version}";
  version = "0.2";

  src = fetchFromGitHub {
    owner = "gauteh";
    repo = "gmailieer";
    rev = "v${version}";
    sha256 = "0ix9j6rb2iss8h6kh46p6ar409r6z3jjlssfh82vgyb51svfvawf";
  };

  propagatedBuildInputs = with python3Packages; [ tqdm google_api_python_client oauth2client notmuch ];
}
