{ home-manager, lib, config, hmConfig, ... }:
let
  cfg = config.bat;

  batOptions = lib.getOptions "${home-manager}/modules/programs/bat.nix";
in
{
  options.bat = {
    inherit (batOptions) enable package;

    enableZshIntegration = lib.mkOption {
      type = lib.types.bool;
      default = hmConfig.home.shell.enableZshIntegration;
      defaultText = lib.literalMD "[](#opt-home.shell.enableZshIntegration)";
      example = false;
      description = "Whether to enable Zsh integration.";
    };
  };
  config.hm.programs = lib.mkIf cfg.enable {
    bat = {
      inherit (cfg) enable package;
    };

    zsh.shellAliases.cat = lib.mkIf cfg.enableZshIntegration "${cfg.package}/bin/bat";
  };
}
