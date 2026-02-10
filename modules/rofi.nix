{ home-manager, pkgs, lib, config, hmConfig, ... }:
let
  inherit (lib)
    mkOption
    mkIf
    mkDefault
    types

    optionalString
    optionalAttrs
    concatMapAttrs
    filterAttrs
    concatMapAttrsStringSep;
  inherit (builtins) isAttrs isString;
  cfgRofi = config.rofi;
  cfgRofiGames = config.rofi-games;

  rofiOptions = lib.getOptions "${home-manager}/modules/programs/rofi.nix";
  tomlFormat = pkgs.formats.toml { };

  rasiLiteral = types.submodule
    {
      options = {
        _type = mkOption {
          type = types.enum [ "literal" ];
          internal = true;
        };

        value = mkOption {
          type = types.str;
          internal = true;
        };
      };
    }
  // {
    description = "Rasi literal string";
  };
  primitive =
    with types;
    (oneOf [
      str
      int
      bool
      rasiLiteral
    ]);
  configType = with types; (either (attrsOf (either primitive (listOf primitive))) str);

  mkValueString =
    value:
    if lib.isBool value then
      if value then "true" else "false"
    else if lib.isInt value then
      toString value
    else if (value._type or "") == "literal" then
      value.value
    else if isString value then
      ''"${value}"''
    else if lib.isList value then
      "[ ${lib.strings.concatStringsSep "," (map mkValueString value)} ]"
    else
      abort "Unhandled value type ${builtins.typeOf value}";
  mkKeyValue =
    { sep ? ": ", end ? ";" }:
    name: value: "${name}${sep}${mkValueString value}${end}";
  mkRasiSection =
    name: value:
    if isAttrs value then
      let
        toRasiKeyValue = lib.generators.toKeyValue { mkKeyValue = mkKeyValue { }; };
        # Remove null values so the resulting config does not have empty lines
        configStr = toRasiKeyValue (filterAttrs (_: v: v != null) value);
      in
      ''
        ${name} {
        ${configStr}}
      ''
    else
      (mkKeyValue
        {
          sep = " ";
          end = "";
        }
        name
        value)
      + "\n";
  toRasi =
    attrs:
    lib.concatStringsSep "\n" (
      lib.concatMap (lib.mapAttrsToList mkRasiSection) [
        (filterAttrs (n: _: n == "@theme") attrs)
        (filterAttrs (n: _: n == "@import") attrs)
        (removeAttrs attrs [
          "@theme"
          "@import"
        ])
      ]
    );

  themeName =
    if (cfgRofi.theme == null) then
      null
    else if (isString cfgRofi.theme) then
      cfgRofi.theme
    else if (isAttrs cfgRofi.theme) then
      "custom"
    else
      lib.removeSuffix ".rasi" (baseNameOf cfgRofi.theme);
in
{
  options.rofi = {
    inherit (rofiOptions) enable package plugins theme;

    config = mkOption {
      type = with types; attrsOf configType;
      default = { };
      description = ''
        Config files to generate for rofi.
      '';
    };

    command = mkOption {
      type = with types; attrsOf str;
      default = null;
      description = ''
        Command to run each configuration.
        This is automatically generated and shouldn't be overriden.
      '';
    };
  };
  options.rofi-games = {
    hide-entries-without-box-art = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = ''
        Allows hiding any entries which don't have box art images defined.
      '';
    };
    box-art-dir = mkOption {
      type = with types; nullOr str;
      default = null;
      description = ''
        Directory to find box art in if an absolute path is not given.
      '';
    };
    fallback-to-icons = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = ''
        If the box art for a game is not found, fallback to using the icon.
      '';
    };
    show-entry-source-text = mkOption {
      type = types.bool;
      default = true;
      example = false;
      description = ''
        Show the source launcher next to the title of each entry.
      '';
    };
    use-bold-entry-title = mkOption {
      type = types.bool;
      default = true;
      example = false;
      description = ''
        Make entry titles bold - recommended if showing the source text.
      '';
    };
  };

  config = mkIf cfgRofi.enable {
    hm.programs.rofi = {
      inherit (cfgRofi) enable package plugins theme;
    };
    hm.xdg.configFile = (concatMapAttrs
      (name: value: {
        "rofi/${name}.rasi".text = (optionalString (value.show != "dmenu")
          (toRasi { configuration = (removeAttrs value [ "show" ]); })
        ) + (optionalString (themeName != null) (toRasi {
          "@theme" = themeName;
        }));
      })
      cfgRofi.config
    ) // {
      "rofi-games/config.toml".source = tomlFormat.generate "config.toml" ({
        hide_entries_without_box_art = cfgRofiGames.hide-entries-without-box-art;
        fallback_to_icons = cfgRofiGames.fallback-to-icons;
        show_entry_source_text = cfgRofiGames.show-entry-source-text;
        use_bold_entry_title = cfgRofiGames.use-bold-entry-title;
      } // optionalAttrs (cfgRofiGames.box-art-dir != null) {
        box_art_dir = cfgRofiGames.box-art-dir;
      });
    };
    rofi.command = mkDefault (builtins.mapAttrs
      (name: value:
        let
          rofiPath = "${hmConfig.programs.rofi.finalPackage}/bin/rofi";
          configPath = "${hmConfig.home.homeDirectory}/${hmConfig.xdg.configFile."rofi/${name}.rasi".target}";
        in
        if value.show == "dmenu" then
          "${rofiPath} -dmenu -config \"${configPath}\" " + (concatMapAttrsStringSep " "
            (name: value: "-${name} ${toString value}")
            (removeAttrs value [ "show" ])
          )
        else
          "${rofiPath} -show ${value.show} -config \"${configPath}\""
      )
      cfgRofi.config
    );

    # Remove home-manager's default config file, because we make our owns
    hm.home.file."${hmConfig.programs.rofi.configPath}".enable = false;
    lib.formats.rasi.mkLiteral = value: {
      _type = "literal";
      inherit value;
    };
  };
}
