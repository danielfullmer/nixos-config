{ config, pkgs, lib, ... }:
{
  environment.systemPackages = (with pkgs; [
    (texlive.combine {
      inherit (texlive) scheme-medium filehook exam pgf pgfplots subfigure preprint;
# collection-latexextra
    })

    git-latexdiff
    proselint

    (python3.buildEnv.override {
      extraLibs = with python3Packages; [
        jupyter
        bpython
        numpy
        sympy
        matplotlib
        seaborn
        pandas
      ];
      ignoreCollisions = true;
    })
  ]);
}
