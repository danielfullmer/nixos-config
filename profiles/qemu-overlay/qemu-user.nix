
self: super:

let
  stableNixpkgs = builtins.fetchTarball {
    # nixos-18.09 as of 2018-12-24
    url = https://github.com/nixos/nixpkgs/archive/b9fa31cea0e119ecf1867af4944ddc2f7633aacd.tar.gz;
    sha256 = "1iqdra7nvcwbydjirjsk71rpzk4ljc0gzqy33fcp8l18y8iwh47k";
  };
  stablePkgs = import stableNixpkgs {};
in
{
  qemu-user-arm = if stablePkgs.stdenv.system == "x86_64-linux"
    then stablePkgs.pkgsi686Linux.callPackage ./qemu { user_arch = "arm"; }
    else stablePkgs.callPackage      ./qemu { user_arch = "arm"; };
  qemu-user-x86 = stablePkgs.callPackage ./qemu { user_arch = "x86_64"; };
  qemu-user-arm64 = stablePkgs.callPackage ./qemu { user_arch = "aarch64"; };
  qemu-user-riscv32 = stablePkgs.callPackage ./qemu { user_arch = "riscv32"; };
  qemu-user-riscv64 = stablePkgs.callPackage ./qemu { user_arch = "riscv64"; };
}
