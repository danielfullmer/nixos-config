{ pkgs }:

pkgs.replaceVarsWith {
  src = ./extlinux-conf-builder.sh;
  isExecutable = true;
  replacements = {
    inherit (pkgs) bash;
    path = [pkgs.coreutils pkgs.gnused pkgs.gnugrep];
  }
}
