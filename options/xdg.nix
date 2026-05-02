{ lib, config, hmConfig, ... }:
let
  inherit (lib) mkDefault mkOption types literalExpression hasPrefix;
  cfg = config.xdg;

  fileType =
    opt: basePathDesc: basePath:
    types.attrsOf (
      types.submodule ({ name, ... }: {
        options = {
          enable = mkOption {
            type = types.bool;
            default = true;
            description = ''
              Whether this file should be generated. This option allows specific
              files to be disabled.
            '';
          };

          target = mkOption {
            type = types.str;
            defaultText = literalExpression "name";
            description = ''
              Path to target file relative to ${basePathDesc}.
            '';
          };

          text = mkOption {
            default = null;
            type = with types; nullOr lines;
            description = ''
              Text of the file. If this option is null then
              [](#opt-${opt}._name_.source)
              must be set.
            '';
          };

          source = mkOption {
            type = types.path;
            description = ''
              Path of the source file or directory. If
              [](#opt-${opt}._name_.text)
              is non-null then this option will automatically point to a file
              containing that text.
            '';
          };

          executable = mkOption {
            type = with types; nullOr bool;
            default = null;
            description = ''
              Set the execute bit. If `null`, defaults to the mode
              of the {var}`source` file or to `false`
              for files created through the {var}`text` option.
            '';
          };

          recursive = mkOption {
            type = types.bool;
            default = false;
            description = ''
              If the file source is a directory, then this option
              determines whether the directory should be recursively
              linked to the target location. This option has no effect
              if the source is a file.
      
              If `false` (the default) then the target
              will be a symbolic link to the source directory. If
              `true` then the target will be a
              directory structure matching the source's but whose leafs
              are symbolic links to the files of the source directory.
            '';
          };

          ignorelinks = mkOption {
            type = types.bool;
            default = false;
            description = ''
              When `recursive` is enabled, adds `-ignorelinks` flag to lndir
      
              It causes lndir to not treat symbolic links in the source directory specially.
              The link created in the target directory will point back to the corresponding
              (symbolic link) file in the source directory. If the link is to a directory
            '';
          };

          onChange = mkOption {
            type = types.lines;
            default = "";
            description = ''
              Shell commands to run when file has changed between
              generations. The script will be run
              *after* the new files have been linked
              into place.
      
              Note, this code is always run when `recursive` is
              enabled.
            '';
          };

          force = mkOption {
            type = types.bool;
            default = false;
            description = ''
              Whether the target path should be unconditionally replaced
              by the managed file source. Warning, this will silently
              delete the target regardless of whether it is a file or
              link.
            '';
          };
        };
        config.target = mkDefault (if hasPrefix "/" name then name else "${basePath}/${name}");
      })
    );
in
{
  options.xdg = {
    configHome = mkOption {
      type = types.path;
      defaultText = "~/.config";
      default = "${hmConfig.home.homeDirectory}/.config";
      apply = toString;
      description = ''
        Absolute path to directory holding application configurations.

        Sets `XDG_CONFIG_HOME` for the user if `xdg.enable` is set `true`.
      '';
    };

    dataHome = mkOption {
      type = types.path;
      defaultText = "~/.local/share";
      default = "${hmConfig.home.homeDirectory}/.local/share";
      apply = toString;
      description = ''
        Absolute path to directory holding application data.

        Sets `XDG_DATA_HOME` for the user if `xdg.enable` is set `true`.
      '';
    };

    cacheFile = mkOption {
      type = fileType "xdg.cacheFile" "{var}`xdg.cacheHome`" hmConfig.xdg.cacheHome;
      default = { };
      description = ''
        Attribute set of files to link into the user's XDG cache home.
      '';
    };

    configFile = mkOption {
      type = fileType "xdg.configFile" "{var}`xdg.configHome`" hmConfig.xdg.configHome;
      default = { };
      description = ''
        Attribute set of files to link into the user's XDG configuration home.
      '';
    };

    dataFile = mkOption {
      type = fileType "xdg.dataFile" "<varname>xdg.dataHome</varname>" hmConfig.xdg.dataHome;
      default = { };
      description = ''
        Attribute set of files to link into the user's XDG data home.
      '';
    };

    stateFile = mkOption {
      type = fileType "xdg.stateFile" "<varname>xdg.stateHome</varname>" hmConfig.xdg.stateHome;
      default = { };
      description = ''
        Attribute set of files to link into the user's XDG
        state home.
      '';
    };
  };
  config.hm.xdg = cfg;
}
