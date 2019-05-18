{ buildPythonPackage, buildPythonApplication, fetchPypi, fetchFromGitHub, tornado_4, pyaxmlparser, pycryptodome, gpapi }:

let
  crontab = buildPythonPackage rec {
    pname = "crontab";
    version = "0.22.5";
    src = fetchPypi {
      inherit pname version;
      sha256 = "05ir9ihl6dj9fzyzprxymq2issbriiq26f9slmqndnkzipm1vpac";
    };
  };
  tornado-crontab = buildPythonPackage rec {
    pname = "tornado-crontab";
    version = "0.4.0";
    src = fetchPypi {
      inherit pname version;
      sha256 = "07kbpphzw6c9wsrl8k50hnnz56057h47vyvc60ahg722cx65r7na";
    };
    propagatedBuildInputs = [ tornado_4 crontab ];
  };
in
buildPythonApplication rec {
  pname = "playmaker";
  version = "0.6.4";
  src = fetchFromGitHub {
    owner = "NoMore201";
    repo = "playmaker";
    rev = "v${version}";
    sha256 = "15qngr074gvm6qk0zb8qnnzwdfzgj759zq789d0acl1f2r5vb53l";
  };

  propagatedBuildInputs = [ pyaxmlparser pycryptodome tornado_4 gpapi tornado-crontab ];
}
