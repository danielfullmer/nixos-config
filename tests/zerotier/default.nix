{ system ? builtins.currentSystem
, config ? { allowUnfree = true; }
, pkgs ? import <nixpkgs> { inherit system config; }
}:

with import <nixpkgs/nixos/lib/testing-python.nix> { inherit system pkgs; };
with pkgs.lib;

# A few connectivity modes to test:
# 1) Direct local network access
# 2) Double-NAT
# TODO:
# 3) No direct connection, all traffic relayed through moon
# 4) Multipath
# 5) Bridging
# 6) UPNP

let
  networkZTConfig = {
    private = false; # Make a public network so we don't have to authorize new hosts
    v4AssignMode.zt = true; # Assign IPv4 addresses to new hosts
    ipAssignmentPools = [
      { ipRangeStart = "30.0.0.1";
        ipRangeEnd = "30.0.0.100";
      }
    ];
    routes = [
      { target = "30.0.0.0/24";
        via = null;
      }
    ];
  };

  # Since we don't have internet access, we must create our own moon
  # We have to generate these secrets manually, at least for moon since it's used to generate .moon file
  moonFiles = ./moonFiles;
  # These were created using the following commands:

  # zerotier-idtool generate identity.secret identity.public
  #
  # # Following instructions from: https://www.zerotier.com/manual.shtml#4_4
  # zerotier-idtool initmoon identity.public > moon.json
  #
  # # Add moon IP address as stable endpoint.
  # cat moon.json | jq '. + {roots: ([.roots[0] + {stableEndpoints: ["10.0.0.1/9993"]}])}' > moon-modified.json
  #
  # # Sign this moon definition
  # zerotier-idtool genmoon moon-modified.json

  common =
    { pkgs, ... }:
    { environment.systemPackages = with pkgs; [ curl jq ];
      services.zerotierone.enable = true;
      nixpkgs.config.allowUnfree = true;

      # Ensure .moon file is available to all nodes
      systemd.services.zerotierone.preStart = ''
        mkdir -p /var/lib/zerotier-one/moons.d
        cp ${moonFiles}/*.moon /var/lib/zerotier-one/moons.d/
      '';
    };

  moon =
    { imports = [ common ];
      systemd.services.zerotierone.preStart = ''
        mkdir -p /var/lib/zerotier-one
        cp ${moonFiles}/identity.{public,secret} /var/lib/zerotier-one/
      '';
    };

  testScript =
    ''
      MACHINES = [ moon, client1, client2 ]

      def wait_for_zerotier(machine):
          machine.wait_for_unit("zerotierone.service")
          machine.wait_for_file("/var/lib/zerotier-one/authtoken.secret")
          machine.wait_for_open_port(9993)

      curl = 'curl -sSf --header "X-ZT1-Auth: $(cat /var/lib/zerotier-one/authtoken.secret)"';

      start_all()

      for m in MACHINES:
          wait_for_zerotier(m)

      controllerZTAddress = moon.succeed(curl + " http://localhost:9993/status | jq -j -e .address")
      networkID = controllerZTAddress + "000001"

      # Create the network on this host
      moon.succeed(curl + " -X POST -d @${pkgs.writeText "controller.json" (builtins.toJSON networkZTConfig)} http://localhost:9993/controller/network/" + networkID)

      for m in MACHINES:
          # Join the network using the command line
          m.succeed("zerotier-cli join " + networkID)

          # Wait for network to be OK
          m.wait_until_succeeds(curl + " http://localhost:9993/network/" + networkID + " | jq -j -e .status | grep -q OK")

          # Get assigned IP address
          m.ZTIPAddress = m.succeed(curl + " http://localhost:9993/network/" + networkID + " | jq -j -e .assignedAddresses[0]").split('/')[0]
          # Ensure we can ping ourself on this zerotier network
          m.wait_until_succeeds("ping -c 1 " + m.ZTIPAddress)

      # Ensure all machines can ping each other
      for client in MACHINES:
          for host in MACHINES:
              if client != host:
                  client.wait_until_succeeds("ping -c 1 " + host.ZTIPAddress)

    '';

  testCases = {
    simple = {
      name = "zerotier-simple";
      inherit testScript;
      nodes = {
        moon = {
          imports = [ moon ];
          networking.interfaces.eth1.ipv4.addresses = mkForce [ { address = "10.0.0.1"; prefixLength = 8; } ];
        };
        client1 = {
          imports = [common];
          networking.interfaces.eth1.ipv4.addresses = mkForce [ { address = "10.0.0.2"; prefixLength = 8; } ];
        };
        client2 = {
          imports = [common];
          networking.interfaces.eth1.ipv4.addresses = mkForce [ { address = "10.0.0.3"; prefixLength = 8; } ];
        };
      };
    };

    doubleNat = {
      name = "zerotier-doubleNat";

      testScript = testScript + ''
        # Additionally ensure client 1 and 2 can't ping each other normally
        client1.fail("ping -c 1 192.168.1.2")
        client2.fail("ping -c 1 192.168.0.2")
      '';

      nodes = {
        moon = {
          imports = [ moon ];
          virtualisation.vlans = [ 1 ];
          networking.interfaces.eth1.ipv4.addresses = mkForce [ { address = "10.0.0.1"; prefixLength = 8; } ];
        };
        router1 = {
          virtualisation.vlans = [ 1 2 ];
          networking.interfaces.eth1.ipv4.addresses = mkForce [ { address = "10.0.0.2"; prefixLength = 8; } ];
          networking.interfaces.eth2.ipv4.addresses = mkForce [ { address = "192.168.0.1"; prefixLength = 24; } ];
          networking.nat.enable = true;
          networking.nat.externalInterface = "eth1";
          networking.nat.internalInterfaces = [ "eth2" ];
        };
        router2 = {
          virtualisation.vlans = [ 1 3 ];
          networking.interfaces.eth1.ipv4.addresses = mkForce [ { address = "10.0.0.3"; prefixLength = 8; } ];
          networking.interfaces.eth2.ipv4.addresses = mkForce [ { address = "192.168.1.1"; prefixLength = 24; } ];
          networking.nat.enable = true;
          networking.nat.externalInterface = "eth1";
          networking.nat.internalInterfaces = [ "eth2" ];
        };
        client1 = {
          imports = [common];
          virtualisation.vlans = [ 2 ];
          networking.interfaces.eth1.ipv4.addresses = mkForce [ { address = "192.168.0.2"; prefixLength = 24; } ];
          networking.interfaces.eth1.ipv4.routes = mkForce [ { address = "0.0.0.0"; prefixLength = 0; via = "192.168.0.1"; } ];
        };
        client2 = {
          imports = [common];
          virtualisation.vlans = [ 3 ];
          networking.interfaces.eth1.ipv4.addresses = mkForce [ { address = "192.168.1.2"; prefixLength = 24; } ];
          networking.interfaces.eth1.ipv4.routes = mkForce [ { address = "0.0.0.0"; prefixLength = 0; via = "192.168.1.1"; } ];
        };
      };
    };
  };

in mapAttrs (const: (attrs: makeTest (attrs // {
  skipLint = true;
}))) testCases
