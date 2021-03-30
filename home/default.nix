{ config, lib, pkgs, ... }:

{
  imports = [
    ./taskwarrior.nix
    ./bugwarrior.nix
  ];

  programs.git = {
    enable = true;
    userName = "Daniel Fullmer";
    userEmail = "danielrf12@gmail.com";
    signing.key = "EF6B0CB0";
  };

  accounts.email = {
    accounts.cgibreak-gmail = {
      address = "cgibreak@gmail.com";
      realName = "Daniel Fullmer";
      primary = true;

      flavor = "gmail.com";
      passwordCommand = "pass google.com/cgibreak-gmail";

      notmuch.enable = true;
      lieer = {
        enable = true;
        sync.enable = true;
        sync.frequency = "*:0/3"; # Every 3 minutes
      };

      astroid.enable = true;
      astroid.sendMailCommand = "sendmail -i -t";
    };

    accounts.dfullmer-aht = {
      address = "dfullmer@aht.ai";
      realName = "Daniel Fullmer";

      flavor = "gmail.com";
      passwordCommand = "pass google.com/dfullmer@aht.ai-gmail";

      notmuch.enable = true;
      lieer = {
        enable = true;
        sync.enable = true;
        sync.frequency = "*:0/3"; # Every 3 minutes
      };

      astroid.enable = true;
      astroid.sendMailCommand = "gmi send -t -C ${config.accounts.email.accounts.dfullmer-aht.maildir.absPath}";
    };
  };

  programs = {
    bash.enable = true;
    zsh.enable = true;
    notmuch = {
      enable = true;
      new.tags = [ "new" ]; # Tag for new mail
    };
    lieer.enable = true;
    astroid = {
      enable = true;
      pollScript =
        lib.concatStringsSep "\n"
          (lib.mapAttrsToList (name: account: "systemctl --user start lieer-${account.name}")
            (lib.filterAttrs (name: account: account.lieer.sync.enable) config.accounts.email.accounts));
      externalEditor = "termite -e \"vim -c 'set ft=mail' '+set fileencoding=utf-8' '+set ff=unix' '+set enc=utf-8' '+set fo+=w' %1\"";
    };
  };

  services.lieer.enable = true;
}
