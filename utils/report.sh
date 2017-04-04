#!/usr/bin/env bash

export NIX_PATH=nixpkgs=https://nixos.org/channels/nixpkgs-unstable/nixexprs.tar.xz
#export NIX_PATH=nixpkgs=/home/danielrf/nixpkgs

rm -rf output
mkdir -p output cache

for name in bellman bellman-vfio nyquist euler; do
    echo "BUILDING: $name"
    nix-build "<nixpkgs/nixos>" -A system -I "nixos-config=machines/${name}.nix" -o result-$name >output/$name.out 2>&1
    if [ $? == 0 ]; then
        echo "SUCCESS";
    else
        echo "FAILED";
    fi
done

echo "RUNNING DESKTOP TEST"
nix-build tests/desktop.nix >output/desktop-test.out 2>&1

echo "PUSHING RESULTS TO LOCAL DIR"
#nix-push result-bellman result-nyquist result-euler --dest cache

echo "UPLOADING TO GDRIVE"
#rclone copy -u cache gdrive2-enc:cache
