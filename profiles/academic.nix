{ config, pkgs, lib, ... }:
{
  environment.systemPackages = (with pkgs; [
    (texlive.combine {
      inherit (texlive) scheme-medium filehook exam pgf pgfplots subfigure preprint;
# collection-latexextra
    })

    git-latexdiff
    proselint

    mendeley
  ]);
}
