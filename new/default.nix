{ pkgs, unstable, lib, ... }:
with lib;
with builtins;
let
  globals = import ./config/globals.nix { inherit pkgs; self = globalsFinal; };
  globalsFinal = globals;

  inputModules = map (filename: ./modules/${filename}) (filter (filename: filename != "utils.nix") (attrNames (readDir ./modules)));
  inputConfigs = map (filename: ./config/${filename}) (filter (filename: filename != "globals.nix") (attrNames (readDir ./config)));
in
{
  _module.args.globals = globalsFinal;
  imports = inputModules ++ inputConfigs;
}
