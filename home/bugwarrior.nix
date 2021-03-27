{ config, pkgs, lib, ... }:
let
  # Needed to serparate configurations so that we can use https_proxy for one of them.
  # TODO: Put tokens into nix-sops somehow? https://github.com/Mic92/sops-nix/issues/62

  commonConfig = {
    general = {
      inline_links = false;
      annotation_links = true;
      annotation_comments = false;
    };
  };

  githubConfig = lib.recursiveUpdate commonConfig {
    general.targets = "my_github";
    my_github = {
      service = "github";
      "github.username" = "danielfullmer";
      "github.login" = "danielfullmer";
      "github.token" = "@oracle:eval:cat $HOME/bugwarrior-github";
      "github.include_repos" = "robotnix";
    };
  };

  ahtConfig = lib.recursiveUpdate commonConfig {
    general.targets = "aht_gitlab";
    aht_gitlab = {
      service = "gitlab";
      "gitlab.login" = "daniel.fullmer";
      "gitlab.token" = "@oracle:eval:cat $HOME/bugwarrior-aht";
      "gitlab.include_repos" = "NM4RA/Backend/ng911-simulator";
      "gitlab.host" = "gitlab.twosix.local";
      "gitlab.verify_ssl" = "False"; # TODO
    };
  };

  mkConfig = name: config: {
    systemd.user.services."bugwarrior-${name}" = {
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.python3Packages.bugwarrior}/bin/bugwarrior-pull";
        Environment = [
          "BUGWARRIORRC=${pkgs.writeText "bugwarrior.rc" (lib.generators.toINI {} config)}"
          "PATH=${lib.makeBinPath (with pkgs; [ taskwarrior gnugrep coreutils ])}"
        ];
      };
    };

    systemd.user.timers."bugwarrior-${name}" = {
      Unit = { Description = "bugwarrior sync with AHT gitlab projects"; };
      Timer = { OnCalendar = "hourly"; Unit = "bugwarrior-${name}.service"; };
      Install = { WantedBy = [ "timers.target" ]; };
    };
  };
in lib.mkMerge [
  (mkConfig "aht" ahtConfig)
  (mkConfig "github" githubConfig)
  {
    # Proxy via aht-relay
    systemd.user.services.bugwarrior-aht.Service.Environment = [ "https_proxy=https://aht-relay:8118" ];
  }
]
