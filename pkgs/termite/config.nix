{ pkgs, theme }:

''
[options]
font = ${theme.fontName} ${theme.fontSize}

'' + (builtins.readFile "${pkgs.base16}/termite/base16-${theme.name}.dark.config")
