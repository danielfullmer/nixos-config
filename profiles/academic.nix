{ config, pkgs, lib, ... }:
{
  environment.systemPackages = (with pkgs; [
    (texlive.combine {
      inherit (texlive) scheme-medium filehook exam pgf pgfplots subfigure;
# collection-latexextra
    })

    git-latexdiff
    pythonPackages.proselint

    (python.buildEnv.override {
      extraLibs = with pythonPackages; [
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
