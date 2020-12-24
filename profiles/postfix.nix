{ config, pkgs, lib, ... }:
{
  services.postfix = {
    enable = true;
    # Thanks to http://rs20.mine.nu/w/2011/07/gmail-as-relay-host-in-postfix/
    # TODO: security options. Cert or password?
    rootAlias = "cgibreak@gmail.com"; # TODO
    config = {
      mynetworks = ["127.0.0.0/8" "30.0.0.0/8"];
      inet_protocols = "ipv4";
      sender_dependent_relayhost_maps = "hash:/etc/postfix.local/relay_maps";
      smtp_use_tls = "yes";
      smtp_sasl_auth_enable = "yes";
      smtp_sasl_password_maps = "hash:/etc/postfix.local/sasl_passwd";
      smtp_sender_dependent_authentication = "yes";
      smtp_sasl_security_options = "noanonymous";
    };
  };
}
