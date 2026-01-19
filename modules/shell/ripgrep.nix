{ home-manager, lib, config, hmConfig, ... }:
let
  cfg = config.ripgrep;

  ripgrepOptions = lib.getOptions "${home-manager}/modules/programs/ripgrep.nix";
in
{
  options.ripgrep = {
    inherit (ripgrepOptions) enable package;

    enableZshIntegration = lib.mkOption {
      type = lib.types.bool;
      default = hmConfig.home.shell.enableZshIntegration;
      defaultText = lib.literalMD "[](#opt-home.shell.enableZshIntegration)";
      example = false;
      description = "Whether to enable Zsh integration.";
    };
  };
  config.hm.programs = lib.mkIf cfg.enable {
    ripgrep = {
      inherit (cfg) enable package;
    };

    zsh.shellAliases.grep = lib.mkIf cfg.enableZshIntegration "${cfg.package}/bin/rg";
  };
}
