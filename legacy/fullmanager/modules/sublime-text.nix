{ lib, pkgs, config, ... }:
let
  inherit (lib)
    types
    mkEnableOption
    mkOption
    mkPackageOption
    mkIf
    literalExpression
    optionalAttrs;
  inherit (builtins)
    filter
    getAttr
    foldl'
    attrNames
    attrValues;
  cfg = config.sublime-text;

  configDirectory = "sublime-text/Packages";
  userConfigDirectory = "${configDirectory}/User";
  jsonFormat = pkgs.formats.json { };
  fontType = (import ./types.nix { inherit lib; }).font;
  attrItems = attrset: lib.mapAttrsToList
    (name: value: { inherit name value; })
    attrset;

  pluginOptions = types.submodule ({ ... }: {
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
      overrides = mkOption {
        type = types.attrsOf types.path;
        default = { };
        description = ''
          Files to override in a plugin.
        '';
      };
    };
  });
  snippetOptions = types.submodule ({ ... }: {
    options = {
      content = mkOption {
        type = types.str;
        example = ''
          Hello, ''${1:this} is a ''${2:snippet}.
        '';
        description = ''
          The content of the snippet.
        '';
      };
      tabTrigger = mkOption {
        type = types.str;
        default = "";
        example = "hello";
        description = ''
          The word that will make the completion appear in the autocompletion.
        '';
      };
      scope = mkOption {
        type = types.str;
        default = "";
        example = "source.python";
        description = ''
          The language scope where the snippet is active.
        '';
      };
      description = mkOption {
        type = types.str;
        default = "";
        description = ''
          A description of the snippet.
        '';
      };
    };
  });
in
{
  options.sublime-text = {
    enable = mkEnableOption "Sublime Text 4";
    package = mkPackageOption pkgs "sublime4" { };

    settings = mkOption {
      type = jsonFormat.type;
      default = { };
      description = ''
        Sublime Text's user settings.
      '';
    };
    font = mkOption {
      type = types.nullOr fontType;
      default = null;
    };
    keymap = mkOption {
      type = jsonFormat.type;
      default = [ ];
    };
    build-systems = mkOption {
      type = jsonFormat.type;
      default = { };
    };
    syntaxes = mkOption {
      type = types.attrsOf types.path;
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
    snippets = mkOption {
      type = types.attrsOf snippetOptions;
      description = ''
        A list of snippets
      '';
    };
  };

  config.hm = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    xdg.configFile = {
      "${userConfigDirectory}/Preferences.sublime-settings".source = jsonFormat.generate "sublime-text-settings" (
        (optionalAttrs (cfg.font != null) {
          font_face = cfg.font.name;
          font_options = cfg.font.features;
        }) // {
          sublime_merge_path = "${pkgs.sublime-merge}/bin/sublime_merge";
        } // cfg.settings
      );
      "${userConfigDirectory}/Default (Linux).sublime-keymap".source = jsonFormat.generate "sublime-text-keymap" cfg.keymap;
      "${userConfigDirectory}/Package Control.sublime-settings".source = jsonFormat.generate "sublime-text-package-control" {
        bootstrapped = true;
        in_process_packages = [ ];
        installed_packages = (filter (plugin_name: (getAttr plugin_name cfg.plugins).managed) (attrNames cfg.plugins)) ++ [ "Package Control" ];
        repositories = filter (repo: repo != null) (map (plugin: plugin.repository or null) (attrValues cfg.plugins));
      };
    } // (foldl'
      (all: { name, value }: all // {
        "${userConfigDirectory}/${name}.sublime-settings".source = jsonFormat.generate "sublime-text-settings-${name}" value.settings;
      })
      { }
      (filter ({ value, ... }: value.settings != { }) (attrItems cfg.plugins))
    ) // (foldl'
      (all: { name, value }:
        let packageName = name; in all // (foldl'
          (all: { name, value }: all // {
            "${configDirectory}/${packageName}/${name}".source = value;
          })
          { }
          (attrItems value.overrides)))
      { }
      (filter ({ value, ... }: value.overrides != { }) (attrItems cfg.plugins))
    ) // (foldl'
      (all: name: all // {
        "${userConfigDirectory}/${name}.sublime-build".source = jsonFormat.generate "sublime-text-build-${name}" (getAttr name cfg.build-systems);
      })
      { }
      (attrNames cfg.build-systems)
    ) // (foldl'
      (all: name: all // {
        "${userConfigDirectory}/${name}.sublime-syntax".source = getAttr name cfg.syntaxes;
      })
      { }
      (attrNames cfg.syntaxes)
    ) // (foldl'
      (all: name: all // {
        "${userConfigDirectory}/${name}.sublime-snippet".text = "
          <snippet>
            <content><![CDATA[${(getAttr name cfg.snippets).content}]]></content>
            <tabTrigger>${(getAttr name cfg.snippets).tabTrigger}</tabTrigger>
            <scope>${(getAttr name cfg.snippets).scope}</scope>
            <description>${(getAttr name cfg.snippets).description}</description>
          </snippet>
        ";
      })
      { }
      (attrNames cfg.snippets)
    );
  };
}
