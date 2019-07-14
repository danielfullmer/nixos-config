{ callPackage, lib, substituteAll, makeWrapper, fetchFromGitHub, jre,
  listenHost ? "localhost",
  port ? 8080,
  domain ? "",
  platformFingerprint ? "",
  deviceFamily ? "",
  avbFingerprint ? ""
}:
let
  buildGradle = callPackage ./gradle-env.nix {};
in
buildGradle {
  pname = "AttestationServer";
  version = "2019-07-14";

  envSpec = ./gradle-env.json;

  src = fetchFromGitHub {
    owner = "grapheneos";
    repo = "AttestationServer";
    rev = "cb580bb94346abfa117d8a2d98fc266f11628e06";
    sha256 = "1gbgg320a8gk70rryp5s4g92j52f0h4ifs7b44p1aqgj4fnv50x8";
  };

  patches = [
    (substituteAll { src = ./0001-Custom-listen-settings.patch; inherit listenHost port; })
  ] ++ lib.optional (domain != "") (substituteAll { src = ./0002-Custom-domain.patch; inherit domain; })
    ++ lib.optional (platformFingerprint != "") (substituteAll {
      src = ./0003-Custom-fingerprints.patch;
      inherit platformFingerprint;
      # TODO: Allow passing in a bunch of fingerprints so multiple custom devices can cross validate each other
      taimen_avbFingerprint = if (deviceFamily == "taimen") then avbFingerprint else "DISABLED_CUSTOM_TAIMEN";
      crosshatch_avbFingerprint = if (deviceFamily == "crosshatch") then avbFingerprint else "DISABLED_CUSTOM_CROSSHATCH";
    });

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
