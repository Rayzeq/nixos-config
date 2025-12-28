{ lib, pkgs, config, ... }:
let
  inherit (lib) mkEnableOption mkOption mkPackageOption mkIf types;
  cfg = config.darkman;

  yamlFormat = pkgs.formats.yaml { };
  scriptsOptionType =
    kind: mkOption {
      type = with types; attrsOf (oneOf [ path lines ]);
      default = { };
      example = lib.literalExpression ''
        {
          gtk-theme = '''
            ''${pkgs.dconf}/bin/dconf write \
                /org/gnome/desktop/interface/color-scheme "'prefer-${kind}'"
          ''';
          my-python-script = pkgs.writers.writePython3 "my-python-script" { } '''
            print('Do something!')
          ''';
        }
      '';
      description = ''
        Scripts to run when switching to "${kind} mode".

        Multiline strings are interpreted as Bash shell scripts and a shebang is
        not required.
      '';
    };
in
{
  options.darkman = {
    enable = mkEnableOption ''
      darkman, a tool that automatically switches dark-mode on and off based on
      the time of the day
    '';
    package = mkPackageOption pkgs "darkman" { nullable = true; };

    settings = mkOption {
      type = with types; submodule { freeformType = yamlFormat.type; };
      default = { };
      example = lib.literalExpression ''
        {
          lat = 52.3;
          lng = 4.8;
          usegeoclue = true;
        }
      '';
      description = ''
        Settings for the {command}`darkman` command. See
        <https://darkman.whynothugo.nl/#CONFIGURATION> for details.
      '';
    };

    darkModeScripts = scriptsOptionType "dark";
    lightModeScripts = scriptsOptionType "light";
  };

  config = mkIf cfg.enable {
    hm.services.darkman = {
      enable = true;
      package = cfg.package;
      settings = cfg.settings;
      darkModeScripts = cfg.darkModeScripts;
      lightModeScripts = cfg.lightModeScripts;
    };
  };
}
