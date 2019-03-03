{ nixpkgs ? { outPath = ./../nixpkgs; revCount = 56789; shortRev = "gfedcba"; }
, stableBranch ? false
, supportedSystems ? [ "x86_64-linux" ]
}:

# See also: https://github.com/openlab-aux/vuizvui
let
  pkgs = import nixpkgs {};
  nixos = nixpkgs + /nixos;
  nixos_tests = (import "${nixos}/release.nix" {}).tests;
in
rec {
  bellman = (import nixos { configuration = ./machines/bellman.nix; }).system;
  bellman-vfio = (import nixos { configuration = ./machines/bellman-vfio.nix; }).system;
  nyquist = (import nixos { configuration = ./machines/nyquist.nix; }).system;
  euler = (import nixos { configuration = ./machines/euler.nix; }).system;
  #banach = (import nixos { configuration = ./machines/banach.nix; }).system;
  spaceheater = (import nixos { configuration = ./machines/spaceheater.nix; }).system;

  tests.desktop = pkgs.lib.hydraJob (import ./tests/desktop.nix {});
  tests.gpg-agent = pkgs.lib.hydraJob (import ./tests/gpg-agent.nix {});
  tests.gpg-agent-x11 = pkgs.lib.hydraJob (import ./tests/gpg-agent-x11.nix {});
  tests.latex-pdf = pkgs.lib.hydraJob (import ./tests/latex-pdf.nix {});
  tests.vim = pkgs.lib.hydraJob (import ./tests/vim.nix {});
  tests.zerotier = pkgs.lib.hydraJob (import ./tests/zerotier.nix {});

  tested = pkgs.releaseTools.aggregate {
    name = "tested";
    constituents =
      let
        # Except for the given systems, return the system-specific constituent
        except = systems: x: map (system: x.${system}) (pkgs.lib.subtractLists systems supportedSystems);
        all = x: except [] x;
      in [
        bellman
        bellman-vfio
        nyquist
        euler
        spaceheater

        tests.desktop
        tests.gpg-agent
        tests.gpg-agent-x11
        tests.latex-pdf
        tests.vim
        tests.zerotier

        # Some nixos tests that are not in release-combined.nix
        (all nixos_tests.bcachefs)
        (all nixos_tests.pam-u2f)
        (all nixos_tests.xss-lock)

        # Below is a subset of release-combined with tests that I care about
        (except ["aarch64-linux"] nixos_tests.installer.lvm)
        (except ["aarch64-linux"] nixos_tests.installer.luksroot)
        (except ["aarch64-linux"] nixos_tests.installer.separateBoot)
        (except ["aarch64-linux"] nixos_tests.installer.separateBootFat)
        (except ["aarch64-linux"] nixos_tests.installer.simple)
        (except ["aarch64-linux"] nixos_tests.installer.simpleLabels)
        (except ["aarch64-linux"] nixos_tests.installer.simpleProvided)
        (except ["aarch64-linux"] nixos_tests.installer.simpleUefiSystemdBoot)
        (except ["aarch64-linux"] nixos_tests.installer.swraid)
        (all nixos_tests.env)
        (all nixos_tests.ipv6)
        (all nixos_tests.i3wm)
        (all nixos_tests.login)
        (all nixos_tests.misc)
        (all nixos_tests.mutableUsers)
        (all nixos_tests.nat.firewall)
        (all nixos_tests.nat.firewall-conntrack)
        (all nixos_tests.nat.standalone)
        (all nixos_tests.networking.scripted.loopback)
        (all nixos_tests.networking.scripted.static)
        (all nixos_tests.networking.scripted.dhcpSimple)
        (all nixos_tests.networking.scripted.dhcpOneIf)
        (all nixos_tests.networking.scripted.bond)
        (all nixos_tests.networking.scripted.bridge)
        (all nixos_tests.networking.scripted.macvlan)
        (all nixos_tests.networking.scripted.sit)
        (all nixos_tests.networking.scripted.vlan)
        (all nixos_tests.openssh)
        (all nixos_tests.predictable-interface-names.predictable)
        (all nixos_tests.predictable-interface-names.unpredictable)
        (all nixos_tests.predictable-interface-names.predictableNetworkd)
        (all nixos_tests.predictable-interface-names.unpredictableNetworkd)
        (all nixos_tests.simple)
      ];
  };

  nixpkgs-tested = (pkgs.releaseTools.channel {
    name = "nixpkgs-tested-channel";
    src = <nixpkgs>;
    constituents = [ tested ];
  }).overrideAttrs (attrs: {
    # Hack until releaseTools.channel may be unified with nixos/lib/make-channel.nix someday
    patchPhase = attrs.patchPhase + ''
      echo -n pre${toString nixpkgs.revCount}.${nixpkgs.shortRev} > .version-suffix
      echo -n ${nixpkgs.rev or nixpkgs.shortRev} > .git-revision
    '';
  });
  config-tested = pkgs.releaseTools.channel {
    name = "config-tested-channel";
    src = pkgs.lib.cleanSource ./.;
    constituents = [ tested ];
  };
}
