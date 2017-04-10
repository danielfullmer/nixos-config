#!/bin/sh
# Used to convert templates from github.com/base16-builder/base16-builder to nix files
echo "{ colors }:"
echo
echo "with colors; ''"
sed -e 's|<%- base\["\(..\)"\]\["hex"\] %>|${base\1}|' $*
echo "''"
