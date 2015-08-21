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
    services.dbus.enable = true;
    #services.bitlbee.enable = true;
    # This rebuilds everything
    #environment.noXlibs = true;

    services.zerotierone.enable = true;
    networking.extraHosts =
        ''
        30.0.0.48 devnull
        30.0.0.154 sysc-2
        30.0.0.200 chromebook
        30.0.0.127 nyquist
        30.0.0.138 bellman
        30.0.0.158 plexbox
        30.0.0.34 wrench
        '';

#    nix.distributedBuilds = true;
#    nix.buildMachines = [
#        { hostName = "nyquist"; maxJobs = 8; sshKey = "/home/danielrf/.ssh/id_rsa"; system="x86_64-linux"; }
#        { hostName = "bellman"; maxJobs = 4; sshKey = "/home/danielrf/.ssh/id_rsa"; system="x86_64-linux"; }
#    ];

    users = {
        extraGroups = [ { name = "danielrf"; } { name = "vboxsf"; } ];
        extraUsers  = [
            {
                description     = "Vagrant User";
                name            = "danielrf";
                group           = "danielrf";
                extraGroups     = [ "users" "wheel" "vboxsf" "docker" "libvirtd"];
                home            = "/home/danielrf";
                createHome      = true;
                #useDefaultShell = true;
                shell = "/run/current-system/sw/bin/zsh";
            }
        ];
    };

    security.sudo.wheelNeedsPassword = false;

    nixpkgs.config = {
        allowUnfree = true;
        #vim.gui = "no";
    };

    environment.systemPackages = (with pkgs; [
        binutils
        pciutils
        usbutils

        git
        tmux
        zsh
        silver-searcher
        psmisc
        htop

        my_vim
        #vim

        zerotierone
        bup
        pandoc

        bitlbee
        weechat

        mutt

        python27
        python34
        python34Packages.ipython
    ]);
}
