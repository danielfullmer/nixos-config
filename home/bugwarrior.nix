{ config, pkgs, lib, ... }:
let
  # Workaround for https://github.com/ralphbean/bugwarrior/issues/805
  # using https://github.com/ralphbean/taskw/pull/141
  bugwarrior = pkgs.python3Packages.bugwarrior.override {
    taskw = pkgs.python3Packages.taskw.overrideAttrs ({ patches ? [], ... }: {
      patches = patches ++ [
        (pkgs.fetchpatch {
          url = "https://github.com/ralphbean/taskw/commit/2c78af798c4844c07b442abd62d4277ce76a6012.patch";
          sha256 = "14501mk6lr9d678z1mb8jq6ja02f4g4rvb8924d1f7hxp7f9nk11";
        })
      ];
    });
  };

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
      "gitlab.include_repos" = "ng911/ng911-simulator";
      "gitlab.host" = "gitlab.aht.ai";
    };
  };

  mkConfig = name: config: {
    systemd.user.services."bugwarrior-${name}" = {
      Service = {
        Type = "oneshot";
        ExecStart = "${bugwarrior}/bin/bugwarrior-pull";
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
]
