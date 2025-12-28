{ pkgs, lib, ... }:
let
  utils = import ./utils.nix;
  globals = import ../configuration/globals.nix { inherit pkgs; self = globalsFinal; };
  globalsFinal = globals;
  inputFiles = builtins.catAttrs "name" (
    builtins.filter
      ({ name, value }: name != "default.nix" && name != "utils.nix")
      (utils.attrItems (builtins.readDir ./.))
  );
  inputFuncs = map (path: import ./${path}) inputFiles;
  inputs = map
    (func: func { inherit pkgs lib; globals = globalsFinal; })
    inputFuncs;
in
{
  user = lib.mkMerge (
    [{
      home.packages = (builtins.concatLists (builtins.catAttrs "packages" inputs));
      services = lib.mkMerge (builtins.catAttrs "services" inputs);
      programs = lib.mkMerge (builtins.catAttrs "programs" inputs);
    }] ++
    (map (input: removeAttrs input [ "packages" "services" "programs" "system" ]) inputs)

  );
  system = lib.mkMerge ((builtins.catAttrs "system" inputs) ++ [{ }]);
}
