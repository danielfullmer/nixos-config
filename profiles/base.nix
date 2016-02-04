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

  nix.extraOptions = ''
    auto-optimize-store = true
  '';
#  nix.distributedBuilds = true;
#  nix.buildMachines = [
#      { hostName = "bellman"; maxJobs = 8; speedFactor = 1; sshUser = "danielrf"; sshKey = "/home/danielrf/.ssh/id_rsa"; system = "x86_64-linux"; supportedFeatures = ["kvm"]; }
#      { hostName = "nyquist"; maxJobs = 4; speedFactor = 2; sshUser = "danielrf"; sshKey = "/home/danielrf/.ssh/id_rsa"; system = "x86_64-linux"; }
#  ];
#  nix.requireSignedBinaryCaches = false; # TODO: Figure out how to make work
  nix.sshServe.enable = true;
  nix.sshServe.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDJ5S+JUOhsRYaiesmryrqTUAv+Mx7mxcq0l7tGaiAPR1DgvwRFqNHokAH7zbwG9ijyY/Dh0i0rzf4AFpWGo2q2kq9Ed8JKHTzvnuc+N+Qnkvut6W60gAvibD0SPEiLEDaPYUy+emXaN95Itq3zDSCG25eK/M8uNGe3iGLVpwIj+L0a7AxmqXgm5Y1BpzZ0zi0+f6+5GMxuUGSCsjFynI9dL6TQ1yS8BbnqbNkWEpNrkZHCEw4G9otVJCazieCswRw/HluX+8ICnD6qBYPFUgKqn7YSqK5OwOsZWRe1kQ7Tj0O4cc5wFKsNXL4eW4TtggYbaf2xGOrhc4WKhTioFbSD vagrant@sysc-2"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDPfbMiEWPKZPkGatfXz1H8LYlS8yqASAn/IKolLRFieo7FYIW9LdNyMZjBmDnhO3O+m5gzbWkAM2kHE2/P4DLeSWcTm6R0kGkn5tjAwG/ncYTUnCNXmxoDFIK07gIzQW540qvJVsvb5h4L8MNm6LHj4YGIpANOgCeDrvet0wgqbF/ogemdSnYL7Aw7+00Cm0mEwZpDqRm49znG8L6OBK9DqWD7ISS991KYxpsxhq5iIXh+oN6fDtakhIkb+gB3lQNRcmHF5IbF2fepGJzOqu36qsEKDj5avHAmL7QP59/mW06pACn07COfSdwqjtt67ua4BQS5she1h6emB8SyU87D danielrf@devnull"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDeHZg3vCd8e3P69xA4yZkhUZ2c5FbT3M+g+8CvUsUoIl1qg981EMVHmDmkDgDBAqwV8ZVaWba1/ERwWWz6CoHY6Pea4ipdyoK/krKCkou+FCZTjfnySzgqZyLmFTejP4OD065DrVBDSnNBHs8sq/90z4MtueCmdsv4PNuRvVj7ECqYYwiqwuKnLnIOm/iHzyjpPkEKAwErLD98t5/+vHMXOuqChm995JzNIaXsX1uOX1Wk9OHcxl1ANEBNjKdBwPnSwvCqJ5/dLDnBUUyTsjuZmk6zxeCkRH+qui5+wRYYeRt6UaqWG5VlFgk2qD8Dt8sKZNc/8a8gDMeIbLPRteN/ danielrf@chromebook"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCw/UqPP9qKeNAkgomcj7DM9HOQ/gdqS2vzva53CVlu3ebyaTuGCPrp4aC08I+Uryvm7uGF5vRUJnWROxJxFWZcdJYIrotXqLY0b0pTyo+h5e6LEoguuoP/ZDFMTESwhVDRXKp7w50l1bxtZocL0Uz6Hke9tzS3BdQtJoaXjhJeyRyLpN31TYXX9fe4T6Zc0IvkH0i4GOoSesuuo8kk2vOSYVtVvXCgaNYCHRlpxPfULZ8x/cTVyXKT5X48rbQACIM8LM6MMxRovYOqhuTHT49ADEb924d+okDGgQ4tNNrtuywSZ2ueU41d2JQt5oU+l2/zfUGeI9GJ+Ei7MkaagEiB danielrf@acid"
    ];

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

    zerotierone
    pandoc

    bitlbee
    weechat
    mutt

    (myEnvFun {
      name = "pyenv";
      buildInputs = with python3Packages; [
        notebook
        bpython
        numpy
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
