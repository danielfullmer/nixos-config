{ config, lib, pkgs, ... }:

{
  imports = [
    ../profiles/base.nix
    ../profiles/interactive.nix
    ../profiles/extended.nix
    ../profiles/yubikey.nix
    ../profiles/syncthing.nix
    ../profiles/desktop/default.nix
    ../profiles/monitors-calibrate.nix
    ../profiles/gaming.nix
    ../profiles/academic.nix
    ../profiles/postfix.nix
    ../profiles/gdrive.nix
    #../profiles/backup.nix
    ../profiles/android.nix
  ];

  theme.base16Name = "chalk";

  system.stateVersion = "18.03";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.rtl8812au ];
  hardware.firmware = [ pkgs.firmwareLinuxNonfree ];  # For any other wifi firmware

  # Current partition status:
  # One bcachefs spanning 1x 500GB SSD and 2x 2Tb HDDs

  boot.initrd.availableKernelModules = [
    "xhci_pci" "ehci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"
  ];

  boot.supportedFilesystems = [ "bcachefs" ];
  boot.initrd.supportedFilesystems = [ "bcachefs" ];

  fileSystems = {
    "/" = {
      device = "//dev/disk/by-partuuid/c3dfea2f-1a6c-4ed0-be71-7c867cd08cc2:/dev/disk/by-partuuid/2f5ccc7a-506e-4f51-973e-4058132e9052:/dev/disk/by-partuuid/31c55194-7364-9748-a547-eef9442d2f51";
      fsType = "bcachefs";
      options = [ "discard" "noatime" ];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/3AF1-2802";
      fsType = "vfat";
    };
  };

  swapDevices = [ ];

  nix.maxJobs = 2;
  nix.buildCores = 4;

  networking.hostName = "bellman"; # Define your hostname.
  networking.hostId = "f6bb12be";
  #networking.wireless.enable = true;
  networking.networkmanager.enable = true;

  services.acpid.enable = true;

  services.xserver.videoDrivers = [ "nvidia" "intel" ];

  services.redshift.enable = true;

  # For Seiki 4K monitor
  fonts.fontconfig.dpi = 115;
  fonts.fontconfig.subpixel.rgba = "bgr";
  theme.fontSize = 12;
#  services.xserver.monitorSection = ''
#    DisplaySize 698 393
#  '';

  services.xserver.xrandrHeads = [
    { output = "DP-0"; primary = true; }
    { output = "DP-4"; }
    { output = "DP-5"; }
    { output = "DVI-D-0";
      monitorConfig = ''
        Option "Rotate" "Left"
      '';
    }
  ];

  # For serial interface to reflash x39 monitor firmware
  services.udev.packages = lib.singleton (pkgs.writeTextFile {
    name = "uart-udev-rules";
    destination = "/etc/udev/rules.d/51-uart-custom.rules";
    text = ''
      SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", ATTRS{product}=="FT232R USB UART", TAG+="uaccess", SYMLINK+="arduino"
    '';
  });

  # For flashing android stuff
  programs.adb.enable = true;
  users.users.danielrf.extraGroups = [ "adbusers" ];

  services.xserver.desktopManager.extraSessionCommands =
    let synergyConfigFile = pkgs.writeText "synergy.conf" ''
      section: screens
          bellman:
          devnull-PC:
          euler-win:
      end
      section: aliases
      end
      section: links
      bellman:
          right = devnull-PC
          down = euler-win
      devnull-PC:
          left = bellman
      euler-win:
          up = bellman
      end
    '';
    in ''
      (${pkgs.synergy}/bin/synergys -c ${synergyConfigFile} -a 30.0.0.222:24800) &
      (yubioath-gui -t) &
      #(keybase-gui) &
      (signal-desktop --start-in-tray) &
    '';

  services.hydra = {
    enable = true;
    hydraURL = "http://${config.networking.hostName}:3000/";
    notificationSender = "cgibreak@gmail.com";
    smtpHost = "${config.networking.hostName}";
    useSubstitutes = true;
    #buildMachinesFiles = [ ../profiles/hydra-remote-machines ];
    # This is a deprecated option, but it's still used by NARInfo.pm
    extraConfig = "binary_cache_secret_key_file = /home/danielrf/nixos-config/secrets/bellman-nix-serve.sec";

    # Patch to allow builtins.fetchTarball
    package = pkgs.hydra.overrideAttrs (attrs: { patches = attrs.patches ++ [ ../pkgs/hydra/no-restrict-eval.patch ]; });
  };

  boot.binfmt.emulatedSystems = [ "armv6l-linux" "armv7l-linux" "aarch64-linux" ];

    # TOOD: Parameterize
    # Used by hydra even if nix.distributedBuilds is false
  nix.buildMachines = [
    { hostName = "localhost";
      #sshUser = "nix";
      #sshKey = "/none";
      system = "x86_64-linux,i686-linux,aarch64-linux";
      maxJobs = 4;
      supportedFeatures = [ "kvm" "nixos-test" "big-parallel" "benchmark" ];
    }
  ];

#  services.home-assistant.enable = true;
#
#  services.tor = {
#    enable = true;
#    hiddenServices."bellman".map = [
#      { port = 22; } # SSH
#      { port = 8123; } # Home-assistant
#    ];
#  };

  systemd.user.services.gmailieer = {
    serviceConfig = {
      ExecStart = "${pkgs.gmailieer}/bin/gmi sync";
      Type = "oneshot";
      WorkingDirectory = "/home/danielrf/mail/cgibreak.gmail";
    };
  };

  systemd.user.timers.gmailieer = {
    requires = [ "network-online.target" ];
    wantedBy = [ "timers.target" ];
    timerConfig = {
      Unit = "gmailieer.service";
      OnCalendar = "*:0/3"; # Every 3 minutes
    };
  };

  environment.systemPackages = with pkgs; [
    bcachefs-tools keyboard-firmware
    signal-desktop
  ];

  system.autoUpgrade.enable = true;
}
