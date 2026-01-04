{ lib, pkgs, config, hmConfig, ... }:
let
  inherit (lib) mkOption mkIf types filterAttrs;
  inherit (builtins) isAttrs isString;
  cfg = config.rofi;

  rofiOptions = (import <home-manager/modules/programs/rofi.nix> {
    inherit lib pkgs;
    config = { };
  }).options.programs.rofi;

  rasiLiteral =
    types.submodule
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
    { sep ? ": "
    , end ? ";"
    ,
    }:
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
    if (cfg.theme == null) then
      null
    else if (isString cfg.theme) then
      cfg.theme
    else if (isAttrs cfg.theme) then
      "custom"
    else
      lib.removeSuffix ".rasi" (baseNameOf cfg.theme);
in
{
  options.rofi = {
    inherit (rofiOptions) enable package plugins theme;

    config = mkOption {
      type = with types; attrsOf configType;
    };

    command = mkOption {
      type = with types; attrsOf str;
    };
  };

  config = mkIf cfg.enable {
    hm.programs.rofi = {
      inherit (cfg) enable package plugins theme;
    };
    hm.xdg.configFile = lib.mapAttrs'
      (name: value:
        lib.nameValuePair
          "rofi/${name}.rasi"
          {
            text = (if value.show == "dmenu" then
              ""
            else
              toRasi { configuration = (removeAttrs value [ "show" ]); }
            ) +
            (lib.optionalString (themeName != null) (toRasi {
              "@theme" = themeName;
            }));
          })
      cfg.config;
    rofi.command = lib.mkDefault (builtins.mapAttrs
      (name: value:
        let
          rofiPath = "${hmConfig.programs.rofi.finalPackage}/bin/rofi";
          configPath = "${hmConfig.home.homeDirectory}/${hmConfig.xdg.configFile."rofi/${name}.rasi".target}";
        in
        if value.show == "dmenu" then
          "${rofiPath} -dmenu -config \"${configPath}\" " + (lib.concatStringsSep " " (
            lib.mapAttrsToList
              (name: value: "-${name} ${toString value}")
              (removeAttrs value [ "show" ])
          ))
        else
          "${rofiPath} -show ${value.show} -config \"${configPath}\""
      )
      cfg.config
    );

    hm.home.file."${hmConfig.programs.rofi.configPath}".enable = false;
    lib.formats.rasi.mkLiteral = value: {
      _type = "literal";
      inherit value;
    };
  };
}
