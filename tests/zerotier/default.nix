import <nixpkgs/nixos/tests/make-test-python.nix> ({ pkgs, lib, ...} :

# A few connectivity modes to test:
# 1) Direct local network access
# 2) uPNP mediated UDP tunneling
# 3) Traffic passing through moon
# 4) Double-nat stuff
# 5) UDP hole punching

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
  # cat moon.json | jq '. + {roots: ([.roots[0] + {stableEndpoints: ["192.168.1.3/9993"]}])}' > moon-modified.json
  #
  # # Sign this moon definition
  # zerotier-idtool genmoon moon-modified.json

  common =
    { pkgs, ... }:
    { environment.systemPackages = with pkgs; [ curl jq ];
      services.zerotierone.enable = true;
      nixpkgs.config.allowUnfree = true;

      # nixpkgs commit fe3da83b7e26b6f7cdde7a457a794c215d16e969 with
      # boot.enableContainers causes "tun" to load at boot.  For some reason
      # this breaks the test.
      # TODO: Fix
      boot.enableContainers = false;

      # Ensure .moon file is available to all nodes
      systemd.services.zerotierone.preStart = ''
        mkdir -p /var/lib/zerotier-one/moons.d
        cp ${moonFiles}/*.moon /var/lib/zerotier-one/moons.d/
      '';
    };
in
rec {
  name = "zerotier";

  skipLint = true;

  nodes = {
    moon =
      { pkgs, ...}:
      { imports = [ common ];
        systemd.services.zerotierone.preStart = ''
          mkdir -p /var/lib/zerotier-one
          cp ${moonFiles}/identity.{public,secret} /var/lib/zerotier-one/
        '';

        networking.interfaces.eth1.ipv4.addresses = lib.mkForce [
          { address = "192.168.1.3"; prefixLength = 24; }
        ];
      };
    controller =
      { pkgs, ...}:
      { imports = [common];
        networking.interfaces.eth1.ipv4.addresses = lib.mkForce [
          { address = "192.168.1.1"; prefixLength = 24; }
        ];
      };
    client =
      { pkgs, ...}:
      { imports = [common];
        networking.interfaces.eth1.ipv4.addresses = lib.mkForce [
          { address = "192.168.1.2"; prefixLength = 24; }
        ];
      };
  };

  testScript =
    { nodes, ... }:
    ''
      curl = 'curl -sSf --header "X-ZT1-Auth: $(cat /var/lib/zerotier-one/authtoken.secret)"';

      start_all()

      moon.wait_for_unit("zerotierone.service")

      ####

      controller.wait_for_unit("zerotierone.service")
      controller.wait_for_file("/var/lib/zerotier-one/authtoken.secret")
      controller.wait_for_open_port(9993)

      controllerZTAddress = controller.succeed(curl + " http://localhost:9993/status | jq -j -e .address")
      networkID = controllerZTAddress + "000001"

      # Create the network on this controller
      controller.succeed(curl + " -X POST -d @${pkgs.writeText "controller.json" (builtins.toJSON networkZTConfig)} http://localhost:9993/controller/network/" + networkID)

      # Join the network using the command line
      controller.succeed("zerotier-cli join " + networkID)

      # Wait for network to be OK
      controller.wait_until_succeeds(curl + " http://localhost:9993/network/" + networkID + " | jq -j -e .status | grep -q OK")

      # Get assigned IP address
      assignedAddress = controller.succeed(curl + " http://localhost:9993/network/" + networkID + " | jq -j -e .assignedAddresses[0]")
      controllerZTIPAddress = assignedAddress.split('/')[0]

      # Ensure we can ping ourself on this zerotier network
      controller.wait_until_succeeds("ping -c 1 " + controllerZTIPAddress)

      ####

      client.wait_for_file("/var/lib/zerotier-one/authtoken.secret")
      client.wait_for_open_port(9993)

      # Join the network set up by controller
      client.succeed("zerotier-cli join " + networkID)

      # Wait for network to be OK
      client.wait_until_succeeds(curl + " http://localhost:9993/network/" + networkID + " | jq -j -e .status | grep -q OK")

      # Get assigned IP address
      assignedAddress = client.succeed(curl + " http://localhost:9993/network/" + networkID + " | jq -j -e .assignedAddresses[0]")
      clientZTIPAddress = assignedAddress.split('/')[0]

      # Ping the controller from the client and vice versa
      controller.wait_until_succeeds("ping -c 1 " + clientZTIPAddress)
      client.wait_until_succeeds("ping -c 1 " + controllerZTIPAddress)

    '';
})
#      ### This works, but there is a painfully long delay before it starts working
#
#      # If we lose direct connectivity, zerotier should still be able to forward traffic through the moon
#
#      # Set up null routes
#      controller.succeed("route add -host 192.168.1.1 reject")
#      controller.succeed("route add -host 192.168.1.2 reject")
#      client.succeed("route add -host 192.168.1.1 reject")
#      client.succeed("route add -host 192.168.1.2 reject")
#
#      controller.wait_until_succeeds("ping -c 1 $clientZTIPAddress")
#      client.wait_until_succeeds("ping -c 1 $controllerZTIPAddress")
