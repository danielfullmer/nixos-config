{ config, pkgs, lib, ... }:

# Using wireguard for mobile phone--zerotier uses too much battery.
# There is an additional UDP forward from home router to bellman on the that
# can be resolved with the unique DNS name so that pixel can directly connect
# to bellman--and it would stay local if the pixel was on the home network
#
# gauss is set up to route default routes. Add 0.0.0.0/0 on the client if desired
#
# TODO: Set IPs in a single location
with lib;
{
  networking.firewall.allowedUDPPorts = [ config.networking.wireguard.interfaces.wg0.listenPort ];
  networking.firewall.trustedInterfaces = [ "wg0" ];
  networking.wireguard.interfaces.wg0 = {
    listenPort = 51820;
    ips = [{
      gauss = "10.200.0.1/24";
      bellman = "10.200.0.2/24";
      pixel3 = "10.200.0.3/24";
      pixel6 = "10.200.0.4/24";
    }.${config.networking.hostName}];
    peers = [
      { # bellman
        publicKey = "OXPGyFb28KWhJBcXtMMOjn5PEUPNGEFtxwBLJsT2+TU=";
        allowedIPs = [ "10.200.0.2/32" ];
      }
      { # pixel3
        publicKey = "U/Qt+Qa/vy+Clw5Aeq2xo9BbZdL2IBttSG2vpafUkQQ=";
        allowedIPs = [ "10.200.0.3/32" ];
      }
      { # pixel6pro
        publicKey = "+LCxY/APMsDo2RK6PiQWU5bfiwMT+NRf7/InKGByBm4=";
        allowedIPs = [ "10.200.0.4/32" ];
      }
      { # gauss
        publicKey = "EaKu1LrJO5PBwrXk5u34fwMa7uzx1J4UF9WTAZA3mWQ=";
        allowedIPs = [ "10.200.0.0/24" ];
        endpoint = "167.71.187.97:${toString config.networking.wireguard.interfaces.wg0.listenPort}";
      }
    ];
    privateKeyFile = config.sops.secrets.wireguard.path;
  };

  sops.secrets.wireguard = {};
}
