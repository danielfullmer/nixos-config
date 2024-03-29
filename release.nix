{ nixpkgs ? <nixpkgs>
, stableBranch ? false
, supportedSystems ? [ "x86_64-linux" ]
}:
with import nixpkgs {config=import ./pkgs/config.nix;};

# See also: https://github.com/openlab-aux/vuizvui
let
  nixos = confFile: (pkgs.nixos (import confFile)).toplevel;
in
rec {
  bellman = nixos ./machines/bellman;
  #bellman-vfio = nixos ./machines/bellman-vfio;
  euler = nixos ./machines/euler;
  banach = nixos ./machines/banach;
  spaceheater = nixos ./machines/spaceheater;
  gauss = nixos ./machines/gauss;

  tests.desktop = lib.hydraJob (import ./tests/desktop.nix {});
  tests.gpg-agent = lib.hydraJob (import ./tests/gpg-agent.nix {});
  tests.gpg-agent-x11 = lib.hydraJob (import ./tests/gpg-agent-x11.nix {});
  tests.latex-pdf = lib.hydraJob (import ./tests/latex-pdf.nix {});
  tests.vim = lib.hydraJob (import ./tests/vim.nix {});
  tests.zerotier.simple = lib.hydraJob (import ./tests/zerotier {}).simple;
  tests.zerotier.doubleNat = lib.hydraJob (import ./tests/zerotier {}).doubleNat;

  tested = releaseTools.aggregate {
    name = "tested";
    constituents = [
        bellman
        #bellman-vfio
        euler
        #spaceheater
        gauss

        tests.desktop
        tests.gpg-agent
        tests.gpg-agent-x11
        tests.latex-pdf
        tests.vim
        tests.zerotier.simple
        tests.zerotier.doubleNat

        # Some nixos tests that are not in release-combined.nix
        #nixosTests.bcachefs
        nixosTests.pam-u2f
        nixosTests.xss-lock

#        # Below is a subset of release-combined with tests that I care about
#        # TODO: Including these increases evaluation time and memory usage too much
#        nixosTests.installer.lvm
#        nixosTests.installer.luksroot
#        nixosTests.installer.separateBoot
#        nixosTests.installer.separateBootFat
#        nixosTests.installer.simple
#        nixosTests.installer.simpleLabels
#        nixosTests.installer.simpleProvided
#        nixosTests.installer.simpleUefiSystemdBoot
#        nixosTests.installer.swraid
#        nixosTests.env
#        nixosTests.ipv6
#        nixosTests.i3wm
#        nixosTests.login
#        nixosTests.misc
#        nixosTests.mutableUsers
#        nixosTests.nat.firewall
#        nixosTests.nat.firewall-conntrack
#        nixosTests.nat.standalone
#        nixosTests.networking.scripted.loopback
#        nixosTests.networking.scripted.static
#        nixosTests.networking.scripted.dhcpSimple
#        nixosTests.networking.scripted.dhcpOneIf
#        nixosTests.networking.scripted.bond
#        nixosTests.networking.scripted.bridge
#        nixosTests.networking.scripted.macvlan
#        nixosTests.networking.scripted.sit
#        nixosTests.networking.scripted.vlan
#        nixosTests.openssh
#        nixosTests.predictable-interface-names.predictable
#        nixosTests.predictable-interface-names.unpredictable
#        nixosTests.predictable-interface-names.predictableNetworkd
#        nixosTests.predictable-interface-names.unpredictableNetworkd
#        nixosTests.simple
      ];
  };

  nixpkgs-tested = (releaseTools.channel {
    name = "nixpkgs-tested-channel";
    src = nixpkgs;
    constituents = [ tested ];
  }).overrideAttrs (attrs: {
    # Hack until releaseTools.channel may be unified with nixos/lib/make-channel.nix someday
    patchPhase = attrs.patchPhase + ''
      echo -n pre${toString nixpkgs.revCount}.${nixpkgs.shortRev} > .version-suffix
      echo -n ${nixpkgs.rev or nixpkgs.shortRev} > .git-revision
    '';
  });
  config-tested = releaseTools.channel {
    name = "config-tested-channel";
    src = lib.cleanSource ./.;
    constituents = [ tested ];
  };
}
