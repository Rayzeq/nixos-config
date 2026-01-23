{ home-manager, pkgs, lib, config, ... }:
let
  inherit (lib) mkOption mkEnableOption mkPackageOption mkIf types;
  cfg = config.discord;

  discordOptions = lib.getOptions "${home-manager}/modules/programs/discord.nix";
  jsonFormat = pkgs.formats.json { };
in
{
  options.discord = {
    inherit (discordOptions) enable package;

    finalPackage = mkOption {
      type = types.package;
      readOnly = true;
      visible = false;
      description = ''
        Resulting discord package.
      '';
    };

    settings = mkOption {
      description = ''
        Configuration for Discord. The schema does not seem to be documented anywhere.
      '';
      default = { };
      example = {
        enable-devtools = true;
      };
      type = types.submodule {
        freeformType = jsonFormat.type;
        options = {
          disable-updates = mkOption {
            type = types.bool;
            default = true;
            example = false;
            description = ''
              Whether to skip Discord's automatic update checks at startup.
            '';
          };

          enable-devtools = mkOption {
            type = types.bool;
            default = false;
            example = true;
            description = ''
              Whether to enable Chrome's devtools inside Discord.
            '';
          };
        };
      };
    };

    openasar = {
      enable = mkEnableOption "OpenAsar";
      package = mkPackageOption pkgs "openasar" { };
    };

    vencord = {
      enable = mkEnableOption "Vencord";
      package = mkPackageOption pkgs "vencord" { };
    };
  };

  config =
    let
      finalPackage = cfg.package.override {
        withOpenASAR = cfg.openasar.enable;
        openasar = cfg.openasar.package;
        withVencord = cfg.vencord.enable;
        vencord = cfg.vencord.package;
      };
    in
    mkIf cfg.enable {
      discord.finalPackage = finalPackage;
      hm.programs.discord = {
        inherit (cfg) enable;
        package = finalPackage;
        settings = {
          SKIP_HOST_UPDATE = cfg.settings.disable-updates;
          DANGEROUS_ENABLE_DEVTOOLS_ONLY_ENABLE_IF_YOU_KNOW_WHAT_YOURE_DOING = cfg.settings.enable-devtools;
          openasar.setup = mkIf cfg.openasar.enable true;
        } // (removeAttrs cfg.settings [ "disable-updates" "enable-devtools" ]);
      };
    }
  ;
}
