{
  description = "My NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    robotnix.url = "github:danielfullmer/robotnix";

    home-manager.url = "github:nix-community/home-manager";

    deploy-rs.url = "github:serokell/deploy-rs";
  };

  outputs = { self, nixpkgs, sops-nix, robotnix, home-manager, deploy-rs }: let
    controlnetModules = [
      sops-nix.nixosModules.sops
      robotnix.nixosModules.attestation-server
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.danielrf = import ./home;
      }
    ];
  in {

    nixosConfigurations = let
      mkSystem = name: system: attrs: nixpkgs.lib.nixosSystem (nixpkgs.lib.recursiveUpdate {
        inherit system;
        modules = [
          (./machines + "/${name}/configuration.nix")
          (./machines + "/${name}/hardware-configuration.nix")
        ] ++ controlnetModules;
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

    # Settings for deploy-rs
    deploy = {
      sshUser = "root";
      user = "root";

      nodes = nixpkgs.lib.mapAttrs (hostname: system: {
        inherit hostname;
        profiles.system.path = deploy-rs.lib.${system.config.nixpkgs.localSystem.system}.activate.nixos system;
      }) self.nixosConfigurations;
    };

    #packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;

    #defaultPackage.x86_64-linux = self.packages.x86_64-linux.hello;

    #checks.x86_64-linux = {};
    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

    hydraJobs = let
      mkTest = system: path:
        nixpkgs.lib.hydraJob
          (import (nixpkgs.legacyPackages.${system}.path + "/nixos/tests/make-test-python.nix")
            (import path)
            { inherit system; pkgs = nixpkgs.legacyPackages.${system}; inherit controlnetModules; }
          );
    in {
      desktop.x86_64-linux = mkTest "x86_64-linux" ./tests/desktop.nix;
      gpg-agent.x86_64-linux = mkTest "x86_64-linux" ./tests/gpg-agent.nix;
      #gpg-agent-x11.x86_64-linux = mkTest "x86_64-linux" ./tests/gpg-agent-x11.nix;
      latex-pdf.x86_64-linux = mkTest "x86_64-linux" ./tests/latex-pdf.nix;
      #vim.x86_64-linux = mkTest "x86_64-linux" ./tests/vim.nix;
      #zerotier-simple.x86_64-linux = (import ./tests/zerotier {}).simple;
      #zerotier-doubleNat.x86_64-linux = (import ./tests/zerotier {}).doubleNat;
    } // nixpkgs.lib.mapAttrs (n: v: { "${v.config.nixpkgs.system}" = v.config.system.build.toplevel; }) self.nixosConfigurations;
  };
}
