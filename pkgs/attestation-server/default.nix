{ callPackage, lib, substituteAll, makeWrapper, fetchFromGitHub, jre,
  listenHost ? "localhost",
  port ? 8080,
  applicationId ? "org.nixdroid.auditor",
  domain ? "example.org",
  signatureFingerprint ? "",
  deviceFamily ? "",
  avbFingerprint ? ""
}:
let
  buildGradle = callPackage ./gradle-env.nix {};
in
buildGradle {
  pname = "AttestationServer";
  version = "2019-08-21";

  envSpec = ./gradle-env.json;

  src = fetchFromGitHub {
    owner = "grapheneos";
    repo = "AttestationServer";
    rev = "03a3c1d44dabbeab8457460ca5e469b9e6a08743";
    sha256 = "0rya7qvibwxq9b586ljlnbhrgxvfvcbsgj5f2663sf5x9hdla2px";
  };

  patches = [ (substituteAll {
    src = ./customized-attestation-server.patch;
    inherit listenHost port domain applicationId signatureFingerprint;

    taimen_avbFingerprint = if (deviceFamily == "taimen") then avbFingerprint else "DISABLED_CUSTOM_TAIMEN";
    crosshatch_avbFingerprint = if (deviceFamily == "crosshatch") then avbFingerprint else "DISABLED_CUSTOM_CROSSHATCH";
  }) ];

  JAVA_TOOL_OPTIONS = "-Dfile.encoding=UTF8";

  outputs = [ "out" "static" ];

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/share/java $out/bin
    mv build/libs/source.jar build/libs/AttestationServer.jar # "source" is just the name of the parent dir in the nix environment, which ought to be "AttestationServer"
    cp -r build/libs/* $out/share/java

    makeWrapper ${jre}/bin/java $out/bin/AttestationServer \
      --add-flags "-cp $out/share/java/AttestationServer.jar:$out/share/java/* app.attestation.server.AttestationServer"

    # Static HTML output
    mkdir -p $static
    cp -r static/* $static
  '';
}
