# From: https://gist.github.com/vlaci/80bebce47a8ac6770035d362b3d004e0

# Usage example in configuration.nix:
#
# {
#   imports = [
#     ./pam-u2f.nix
#   ];
#
#   hardware.u2f.enable = true;
#   security.pam.enableU2F = true;
#   security.pam.use2Factor = true;
#   security.pam.u2fModuleArgs = "cue";
#   security.pam.services."sudo".use2Factor = false;
# }

{ config, pkgs, lib, ... }: with lib;

let
  parentConfig = config;
  overrideServices = { name, config, ...}: {
    options = {
        use2Factor = mkOption {
          description = "If set to true u2f is used as 2nd factor.";
          default = parentConfig.security.pam.use2Factor;
        };
        u2fModuleArgs = mkOption {
          description = "Additional arguments to pass to pam_u2f.so";
          default = parentConfig.security.pam.u2fModuleArgs;
        };
        text = mkOption {
          apply = txt:
            let
              ctrl = if config.use2Factor then "required" else "sufficient";
              args = config.u2fModuleArgs;
            in
              builtins.replaceStrings
                ["auth sufficient ${pkgs.pam_u2f}/lib/security/pam_u2f.so"]
                ["auth ${ctrl} ${pkgs.pam_u2f}/lib/security/pam_u2f.so ${args}"]
                txt;
        };
    };
  };
in
  {
    options = {
      security.pam.services = mkOption {
        type = with types; loaOf (submodule overrideServices);
      };
      security.pam.u2fModuleArgs = mkOption {
        description = ''
          Additional arguments to pass to pam_u2f.so in all pam services.
          A service definitian may override this setting.
        '';
        example = "cue";
        default = "";
      };
      security.pam.use2Factor = mkOption {
        description = ''
          If set to true u2f is used as 2nd factor in all pam services.
          A service definitian may override this setting.
        '';
        default = false;
      };
    };
  }
