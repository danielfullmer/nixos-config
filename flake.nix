{
  description = "My NixOS configurations";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.sops-nix.url = "github:Mic92/sops-nix";
  inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, sops-nix }: {

    nixosConfigurations = let
      mkSystem = name: system: attrs: nixpkgs.lib.nixosSystem (nixpkgs.lib.recursiveUpdate {
        inherit system;
        modules = [
          (./machines + "/${name}/configuration.nix")
          (./machines + "/${name}/hardware-configuration.nix")
          sops-nix.nixosModules.sops
        ];
      } attrs);
    in {
      # Main desktop
      bellman = mkSystem "bellman" "x86_64-linux" {};
      # Laptop (surface pro 4)
      euler = mkSystem "euler" "x86_64-linux" {};
      # Laptop (pinebook pro)
      laplace = mkSystem "laplace" "aarch64-linux" {};
      # Cloud-hosted instance
      gauss = mkSystem "gauss" "x86_64-linux" {};
      # RPI 3
      banach = mkSystem "banach" "aarch64-linux" {};
      # RPI 1
      #tarski = nixpkgs.lib.nixosSystem { system = "armv6l-linux"; modules = [ ./machines/tarski ]; };

      # AHT relay
      aht-relay = mkSystem "aht-relay" "x86_64-linux" {};
    };

    #packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;

    #defaultPackage.x86_64-linux = self.packages.x86_64-linux.hello;

    checks.x86_64-linux = {
      #desktop = nixpkgs.lib.hydraJob (import ./tests/desktop.nix {});
      #gpg-agent = nixpkgs.lib.hydraJob (import ./tests/gpg-agent.nix {});
      #gpg-agent-x11 = nixpkgs.lib.hydraJob (import ./tests/gpg-agent-x11.nix {});
      #latex-pdf = nixpkgs.lib.hydraJob (import ./tests/latex-pdf.nix {});
      #vim = nixpkgs.lib.hydraJob (import ./tests/vim.nix {});
      #zerotier-simple = (import ./tests/zerotier {}).simple;
      #zerotier-doubleNat = (import ./tests/zerotier {}).doubleNat;
    };

    hydraJobs = let
      mkTest = system: path:
        nixpkgs.lib.hydraJob
          (import (nixpkgs.legacyPackages.${system}.path + "/nixos/tests/make-test-python.nix")
            (import path)
            { inherit system; pkgs = nixpkgs.legacyPackages.${system}; }
          );
    in {
      desktop.x86_64-linux = mkTest "x86_64-linux" ./tests/desktop.nix;
      gpg-agent.x86_64-linux = nixpkgs.lib.hydraJob (import ./tests/gpg-agent.nix {});
      gpg-agent-x11.x86_64-linux = nixpkgs.lib.hydraJob (import ./tests/gpg-agent-x11.nix {});
      latex-pdf.x86_64-linux = nixpkgs.lib.hydraJob (import ./tests/latex-pdf.nix {});
      vim.x86_64-linux = nixpkgs.lib.hydraJob (import ./tests/vim.nix {});
      zerotier-simple.x86_64-linux = (import ./tests/zerotier {}).simple;
      zerotier-doubleNat.x86_64-linux = (import ./tests/zerotier {}).doubleNat;
    } // nixpkgs.lib.mapAttrs (n: v: { "${v.config.nixpkgs.system}" = v.config.system.build.toplevel; }) self.nixosConfigurations;
  };
}
