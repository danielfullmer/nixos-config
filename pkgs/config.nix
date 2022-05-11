{
  allowUnfree = true;
  android_sdk.accept_license = true;
  retroarch = {
    enableSnes9x = true;
    enableMupen64Plus = true;
    enableMGBA = true;
    enableNestopia = true;
    enableScummVM = true;
  };
  packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };
}
