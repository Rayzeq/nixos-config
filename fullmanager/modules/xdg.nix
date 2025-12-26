{ lib, config, ... }:
let
  inherit (lib) mkOption mkIf types;
  cfg = config.xdg;

  fileType = types.submodule ({ name, ... }: {
    options = {
      target = mkOption {
        type = with types; str;
      };

      source = mkOption {
        type = types.path;
        description = ''
          Path of the source file or directory.
        '';
      };

      force = mkOption {
        type = with types; bool;
        default = false;
        description = ''
          Whether the target path should be unconditionally replaced
          by the managed file source. Warning, this will silently
          delete the target regardless of whether it is a file or
          link.
        '';
      };
    };
    config = {
      target = lib.mkDefault "/home/zacharie/.local/share/${name}";
    };
  });
in
{
  options.xdg = {
    dataFile = mkOption {
      type = with types; attrsOf fileType;
    };
  };
  config = {
    hm.xdg = cfg;
  };
}
