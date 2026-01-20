{
  description = "My NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    #nixpkgs.url = "github:danielfullmer/nixpkgs/my-nixos-config";

    flake-compat.url = "github:edolstra/flake-compat";
    flake-compat.flake = false;

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nvidia-vgpu.url = "github:danielfullmer/nixos-nvidia-vgpu";

    pinebook-pro.url = "github:samueldr/wip-pinebook-pro";
    pinebook-pro.flake = false;

    jetpack-nixos.url = "github:anduril/jetpack-nixos";

    jovian-nixos.url = "github:Jovian-Experiments/Jovian-NixOS";
  };

  outputs = { self, nixpkgs, sops-nix, home-manager, nvidia-vgpu, pinebook-pro, flake-compat, jetpack-nixos, jovian-nixos, ... }@inputs: let
    mkSystem = name: system: extraConfig: nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        (./machines + "/${name}/configuration.nix")
        (./machines + "/${name}/hardware-configuration.nix")
        self.nixosModules.base
      ] ++ [ extraConfig ];
      specialArgs.flakeInputs = inputs;
    };
  in {
    nixosConfigurations = {
      # Main desktop
      bellman = mkSystem "bellman" "x86_64-linux" {};
      # Laptop (Framework AMD 7040 series)
      riemann = mkSystem "riemann" "x86_64-linux" {};
      # Old 11th gen Intel Framework board in Cooler master case
      fourier = mkSystem "fourier" "x86_64-linux" {};
      # ASUS ROG Ally (Steam deck clone)
      kelvin = mkSystem "kelvin" "x86_64-linux" {
        imports = [ jovian-nixos.nixosModules.default ];
      };
      # Laptop (pinebook pro)
      #laplace = mkSystem "laplace" "aarch64-linux" ({ config, lib, pkgs, ... }: {
      #  imports = [ "${pinebook-pro}/pinebook_pro.nix" ];
      #});
      # Cloud-hosted instance
      gauss = mkSystem "gauss" "x86_64-linux" {};
      # RPI 3
      #banach = mkSystem "banach" "aarch64-linux" {};
      # RPI 1
      #tarski = nixpkgs.lib.nixosSystem { system = "armv6l-linux"; modules = [ ./machines/tarski ]; };
      # Orin AGX devkit
      noether = mkSystem "noether" "aarch64-linux" {};
      # Banana Pi R3 wifi router
      viterbi = mkSystem "viterbi" "aarch64-linux" {};

#      example = nixpkgs.lib.nixosSystem { system="x86_64-linux"; modules = [ self.nixosModules.base {
#        imports = [
#          self.nixosModules.interactive
#          self.nixosModules.desktop
#        ];
#        users.users.dfullmer = {
#          isNormalUser = true;
#          initialPassword = "changeme";
#        };
#      }]; };
    };

    nixosModules = {
      base = {
        imports = [
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          nvidia-vgpu.nixosModules.nvidia-vgpu
          jetpack-nixos.nixosModules.default
          ({ config, lib, ... }: lib.mkIf (config.networking.hostName == "bellman") {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.danielrf = import ./home;
          })
          ({
            nix.registry.nixpkgs.flake = nixpkgs;
          })
          (import ./profiles/base.nix)
        ];
      };
      interactive = import ./profiles/interactive.nix;
      desktop = import ./profiles/desktop;
    };

    packages.x86_64-linux.tftpboot = import ./tftpboot.nix {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      pxeSystems = {
        "01-b8-27-eb-9d-0f-b0" = mkSystem "banach" "aarch64-linux" {
          imports = [ ./profiles/pxe-client.nix ];
          boot.initrd.availableKernelModules = [ "smsc95xx" ]; # For RPI3Bv1.2 networking
        };
      };
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
      gpg-agent.x86_64-linux = mkTest "x86_64-linux" ./tests/gpg-agent.nix;
      #gpg-agent-x11.x86_64-linux = mkTest "x86_64-linux" ./tests/gpg-agent-x11.nix;
      latex-pdf.x86_64-linux = mkTest "x86_64-linux" ./tests/latex-pdf.nix;
      #vim.x86_64-linux = mkTest "x86_64-linux" ./tests/vim.nix;
      #zerotier-simple.x86_64-linux = (import ./tests/zerotier {}).simple;
      #zerotier-doubleNat.x86_64-linux = (import ./tests/zerotier {}).doubleNat;
    } // nixpkgs.lib.mapAttrs (n: v: { "${v.config.nixpkgs.system}" = v.config.system.build.toplevel; }) self.nixosConfigurations;
  };
}
