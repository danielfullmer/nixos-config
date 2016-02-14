{ config, pkgs, lib, ... }:
let
  my_vim = lib.overrideDerivation pkgs.vim_configurable (o: {
    luaSupport = true;
    pythonSupport = true;
    python3Support = true;
    rubySupport = true;
    tclSupport = true;
  });
in {
  services.openssh.enable = true;

  networking.domain = "controlnet";

  services.zerotierone.enable = true;
  networking.firewall.trustedInterfaces = [ "zt0" ];
  networking.extraHosts = ''
    30.0.0.48 devnull
    30.0.0.154 sysc-2
    30.0.0.127 nyquist
    30.0.0.222 bellman
    30.0.0.34 wrench
    30.0.0.86 euler
    30.0.0.84 gauss
    '';

  nix = {
    extraOptions = ''
      auto-optimize-store = true
    '';
    trustedUsers = [ "root" "danielrf" "nixBuild" ];
  };

  users = {
    extraGroups = [ { name = "danielrf"; } { name = "vboxsf"; } ];
    extraUsers  = [
      {
        description     = "Daniel Fullmer";
        name            = "danielrf";
        group           = "danielrf";
        extraGroups     = [ "users" "wheel" "video" "audio" "networkmanager" "vboxsf" "docker" "libvirtd"];
        home            = "/home/danielrf";
        createHome      = true;
        password        = "changeme";
        shell           = "/run/current-system/sw/bin/zsh";
        openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDMTGWu4gkXsWewBZg5if04qt5lyEAKwhi12wmn5e2hKvVLlTlIq8gGBF7d/Xv8G2NlHRsNkugeYyBtB2qfkPWtcDnd1+ws78UTUbYDPpZJzRnIjUEzAg8Q5DzgD9feGHmpONmsr6K71ZGJFwQH2Vf8RHzYIzAYPY85raQiV2Akpw9QtWjp48sNUKoJ75ZWZWzQdJtouJYZRnrK+gweKVWFB0cv7qrIgSOFHAjGJLON+cMXN+T/VIDSZITCRcVLBMlYYGv5NZecspRPO1UV0bgWNHZ3dZwJOEk6cPYUdyA/761zhCWCUc7MJH5xEz3sxcqBSmxtwFYvDFDWkWYcD1gh yubikey"
        ];
      }
    ];
  };

  services.cron.mailto = "cgibreak@gmail.com";

  time.timeZone = "America/New_York";

  security.sudo.wheelNeedsPassword = false;

  nixpkgs.config = {
    allowUnfree = true;
  };

  environment.systemPackages = (with pkgs; [
    binutils
    pciutils
    usbutils
    psmisc
    htop

    tmux

    silver-searcher
    git

    my_vim
    #vim
    emacs

    zerotierone
    pandoc

    bitlbee
    weechat
    mutt
    taskwarrior

    (myEnvFun {
      name = "pyenv";
      buildInputs = with python3Packages; [
        ipython
        notebook
        bpython
        numpy
        #sympy
        matplotlib
        pandas
      ];
    })
    #    (python3.buildEnv.override {
    #      extraLibs = with python3Packages; [
    #        #      ipython
    #        notebook
    #        bpython
    #        numpy
    #        matplotlib
    #        pandas
    #        #        sympy
    #      ];
    #    })
  ]);

  programs.zsh.enable = true;

  environment.variables = {
    EDITOR = "vim";
  };
}
