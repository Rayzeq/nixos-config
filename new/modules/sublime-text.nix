{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.programs.sublime-text;
  jsonFormat = pkgs.formats.json { };
  fontType = (import ./utils.nix { inherit lib; }).types.font;
  pluginOptions = types.submodule ({ config, ... }: {
    options = {
      managed = mkOption {
        type = types.bool;
        default = true;
        example = false;
        description = ''
          Whether this plugin is managed by Package Control.
        '';
      };
      repository = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "https://github.com/facelessuser/SublimeRandomCrap";
        description = ''
          The repository from which to pull the plugin.
        '';
      };
      settings = mkOption {
        type = jsonFormat.type;
        default = { };
        description = ''
          The plugin's settings.
        '';
      };
    };
  });
in
{
  options.programs.sublime-text = {
    enable = mkEnableOption "Sublime Text 4";
    package = mkPackageOption pkgs "sublime4" { };

    settings = mkOption {
      type = jsonFormat.type;
      default = { };
      description = ''
        Sublime Text's user settings.
      '';
    };
    font = fontType;
    keymap = mkOption {
      type = jsonFormat.type;
      default = [ ];
    };
    build-systems = mkOption {
      type = jsonFormat.type;
      default = { };
    };
    plugins = mkOption {
      type = types.attrsOf pluginOptions;
      description = ''
        Installed plugin and their configuration.
      '';
      example = literalExpression ''
        {
          LSP = {
            lsp_format_on_save = true;
            lsp_code_actions_on_save = {
              "source.fixAll" = true;
              "source.addMissingImports" = true;
              "source.organizeImports" = true;
            };
            show_inlay_hints = true;
            default_clients = {};
            clients = {
              nixd = {
                enabled = true;
                command = [ "nixd" ];
                selector = "source.nix";
              };
            };
          };
        };
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      cfg.package
      # nixd is broken, so we need to add this package globally
      pkgs.nixpkgs-fmt
    ] ++ optional (cfg.font.package != null) cfg.font.package;
    nixpkgs.config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "openssl-1.1.1w"
      ];
    };

    xdg.configFile = {
      "sublime-text/Packages/User/Preferences.sublime-settings".source = jsonFormat.generate "sublime-text-settings" (
        optionalAttrs (cfg.font.name != null)
          {
            font_face = cfg.font.name;
          } //
        optionalAttrs (cfg.font.size != null)
          {
            font_size = cfg.font.size;
          } //
        {
          font_options = cfg.font.features;
          sublime_merge_path = "${pkgs.sublime-merge}/bin/sublime_merge";
        } //
        cfg.settings
      );
      "sublime-text/Packages/User/Default (Linux).sublime-keymap".source = jsonFormat.generate "sublime-text-keymap" cfg.keymap;
      "sublime-text/Packages/User/Package Control.sublime-settings".source = jsonFormat.generate "sublime-text-package-control" {
        bootstrapped = true;
        in_process_packages = [ ];
        installed_packages = (filter (plugin_name: (getAttr plugin_name cfg.plugins).managed) (attrNames cfg.plugins)) ++ [ "Package Control" ];
        repositories = filter (repo: repo != null) (map (plugin: plugin.repository or null) (attrValues cfg.plugins));
      };
    } // (foldl'
      (all: name: all // {
        "sublime-text/Packages/User/${name}.sublime-settings".source = jsonFormat.generate "sublime-text-settings-${name}" ((getAttr name cfg.plugins).settings or { });
      })
      { }
      (attrNames cfg.plugins)
    ) // (foldl'
      (all: name: all // {
        "sublime-text/Packages/User/${name}.sublime-build".source = jsonFormat.generate "sublime-text-build-${name}" (getAttr name cfg.build-systems);
      })
      { }
      (attrNames cfg.build-systems)
    );
  };
}
