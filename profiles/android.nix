{ pkgs, ... }:

# Supporting configuration for android devices
{
  services.playmaker.enable = true; # Port 5000 (customize in future)
  # Port 5000 has no access control--anyone who can connect can add/remove packages.
  # We'll rely on firewall to ensure only zerotier network can access port 5000,
  # and additionally pass through the fdroid repo it generates via nginx.
  services.nginx.virtualHosts.localhost.locations."/playmaker/".proxyPass = "http://127.0.0.1:5000/";
  services.nginx.virtualHosts.localhost.locations."/fdroid/".proxyPass = "http://127.0.0.1:5000/fdroid/";
}
