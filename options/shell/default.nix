{ home-manager, pkgs, lib, config, ... }:
let
  inherit (lib) mkOption mkIf types;
  cfg = config;

  homeOptions = lib.getOptions "${home-manager}/modules/home-environment.nix";
in
{
  options = {
    inherit (homeOptions) shellAliases;

    defaultShell = mkOption {
      type = with types; nullOr (either package str);
      default = null;
      example = lib.literalExpression "pkgs.zsh";
      description = ''
        Which shell to be set as the default for users.
      '';
    };
  };
  config = {
    hm.home.shellAliases = cfg.shellAliases;
    system = mkIf (cfg.defaultShell != null) (
      let
        package =
          if builtins.typeOf cfg.defaultShell == "string" then
            if cfg.defaultShell == "zsh" then pkgs.zsh else throw "Unknown shell"
          else
            cfg.defaultShell;
      in
      {
        environment.shells = [ package ];
        users.defaultUserShell = package;
      }
    );
  };
}
