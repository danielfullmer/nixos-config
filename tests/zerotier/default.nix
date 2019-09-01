import <nixpkgs/nixos/tests/make-test.nix> ({ pkgs, ...} :

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
  # # Add moon IP address as stable endpoint. This IP address depends on the ordering of the nodes :(
  # # TODO: Make robust to reordering
  # cat moon.json | jq '. + {roots: ([.roots[0] + {stableEndpoints: ["192.168.1.3/9993"]}])}' > moon-modified.json
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
in
rec {
  name = "zerotier";

  nodes = {
    moon =
      { pkgs, ...}: {
        imports = [common];
        systemd.services.zerotierone.preStart = ''
          mkdir -p /var/lib/zerotier-one
          cp ${moonFiles}/identity.{public,secret} /var/lib/zerotier-one/
        '';
      };
    controller = { pkgs, ...}: { imports = [common]; };
    client = { pkgs, ...}: { imports = [common]; };
  };

  testScript =
    { nodes, ... }:
    ''
      my $curl = "curl -sSf --header \"X-ZT1-Auth: \$(cat /var/lib/zerotier-one/authtoken.secret)\"";

      startAll;

      $moon->waitForUnit("zerotierone.service");

      ####

      $controller->waitForUnit("zerotierone.service");
      $controller->waitForFile("/var/lib/zerotier-one/authtoken.secret");
      $controller->waitForOpenPort(9993);

      my $controllerZTAddress = $controller->succeed("$curl http://localhost:9993/status | jq -j -e .address");
      my $networkID = $controllerZTAddress . "000001";

      # Create the network on this controller
      $controller->succeed("$curl -X POST -d @${pkgs.writeText "controller.json" (builtins.toJSON networkZTConfig)} http://localhost:9993/controller/network/$networkID");

      # Join the network using the command line
      $controller->succeed("zerotier-cli join $networkID");

      # Wait for network to be OK
      $controller->waitUntilSucceeds("$curl http://localhost:9993/network/$networkID | jq -j -e .status | grep -q OK");

      # Get assigned IP address
      my $assignedAddress = $controller->succeed("$curl http://localhost:9993/network/$networkID | jq -j -e .assignedAddresses[0]");
      (my $controllerZTIPAddress) = ($assignedAddress =~ /(30.0.0.\d+)\/24/);

      # Ensure we can ping ourself on this zerotier network
      $controller->waitUntilSucceeds("ping -c 1 $controllerZTIPAddress");

      ####

      $client->waitForFile("/var/lib/zerotier-one/authtoken.secret");
      $client->waitForOpenPort(9993);

      # Join the network set up by controller
      $client->succeed("zerotier-cli join $networkID");

      # Wait for network to be OK
      $client->waitUntilSucceeds("$curl http://localhost:9993/network/$networkID | jq -j -e .status | grep -q OK");

      # Get assigned IP address
      my $assignedAddress = $client->succeed("$curl http://localhost:9993/network/$networkID | jq -j -e .assignedAddresses[0]");
      (my $clientZTIPAddress) = ($assignedAddress =~ /(30.0.0.\d+)\/24/);

      # Ping the controller from the client and vice versa
      $controller->waitUntilSucceeds("ping -c 1 $clientZTIPAddress");
      $client->waitUntilSucceeds("ping -c 1 $controllerZTIPAddress");

#      ### This works, but there is a painfully long delay before it starts working
#
#      # If we lose direct connectivity, zerotier should still be able to forward traffic through the moon
#
#      # Set up null routes
#      $controller->succeed("route add -host 192.168.1.1 reject");
#      $controller->succeed("route add -host 192.168.1.2 reject");
#      $client->succeed("route add -host 192.168.1.1 reject");
#      $client->succeed("route add -host 192.168.1.2 reject");
#
#      $controller->waitUntilSucceeds("ping -c 1 $clientZTIPAddress");
#      $client->waitUntilSucceeds("ping -c 1 $controllerZTIPAddress");
    '';

})
