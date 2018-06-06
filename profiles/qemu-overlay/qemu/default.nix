{ stdenv, fetchurl, python, pkgconfig, zlib, glib, user_arch, flex, bison,
makeStaticLibraries, glibc, qemu, fetchFromGitHub }:

let
  env2 = makeStaticLibraries stdenv;
  myglib = glib.override { stdenv = env2; };
  riscv_src = fetchFromGitHub {
    owner = "riscv";
    repo = "riscv-qemu";
    rev = "7d2d2add16aff0304ab0c279152548dbd04a2138"; # riscv-all
    sha256 = "16an7ifi2ifzqnlz0218rmbxq9vid434j98g14141qvlcl7gzsy2";
  };
  is_riscv = (user_arch == "riscv32") || (user_arch == "riscv64");
in
stdenv.mkDerivation rec {
  name = "qemu-user-${user_arch}-${version}";
  version = "2.11.1";
  src = if is_riscv then riscv_src else qemu.src;
  buildInputs = [ python pkgconfig zlib.static myglib flex bison glibc.static ];
  patches = [ ./qemu-stack.patch ];
  configureFlags = [
    "--enable-linux-user" "--target-list=${user_arch}-linux-user"
    "--disable-bsd-user" "--disable-system" "--disable-vnc"
    "--disable-curses" "--disable-sdl" "--disable-vde"
    "--disable-bluez" "--disable-kvm"
    "--static"
    "--disable-tools"
  ];
  NIX_LDFLAGS = [ "-lglib-2.0" ];
  enableParallelBuilding = true;
  postInstall = ''
    cc -static ${./qemu-wrap.c} -D QEMU_ARM_BIN="\"qemu-${user_arch}"\" -o $out/bin/qemu-wrap
  '';
}
