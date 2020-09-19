{
  description = "My NixOS configurations";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {

    nixosConfigurations = {
      # Main desktop
      bellman = nixpkgs.lib.nixosSystem { system = "x86_64-linux"; modules = [ ./machines/bellman ]; };
      # Laptop (surface pro 4)
      euler = nixpkgs.lib.nixosSystem { system = "x86_64-linux"; modules = [ ./machines/euler ]; };
      # Laptop (pinebook pro)
      laplace = nixpkgs.lib.nixosSystem { system = "aarch64-linux"; modules = [ ./machines/laplace ]; };
      # Cloud-hosted instance
      gauss = nixpkgs.lib.nixosSystem { system = "x86_64-linux"; modules = [ ./machines/gauss ]; };
      # RPI 3
      banach = nixpkgs.lib.nixosSystem { system = "aarch64-linux"; modules = [ ./machines/banach ]; };
      # RPI 1
      #tarski = nixpkgs.lib.nixosSystem { system = "armv6l-linux"; modules = [ ./machines/tarski ]; };
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
  };
}
