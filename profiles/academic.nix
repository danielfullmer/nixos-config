{ config, pkgs, lib, ... }:
{
  environment.systemPackages = (with pkgs; [
    (texlive.combine {
      inherit (texlive) scheme-medium filehook exam pgf pgfplots subfigure preprint;
      #collection-latexrecommended
    })

    git-latexdiff
    proselint

    zotero # mendeley alternative
    #papis # CLI mendeley alternative
    rmapi # Remarkable API
  ]);

  # Zotero connector extension
  programs.chromium.extensions = [ "ekhagklcjbdpajgpjgmbionohlpdbjgc" ];
}
