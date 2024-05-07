{ pkgs, unstable, lib, ... }:
let
  utils = import ./utils.nix;
  globals = import ../configuration/globals.nix { inherit pkgs; self = globalsFinal; };
  globalsFinal = globals // {
    dataFile = (builtins.mapAttrs
      (name: value: value // { target = "/home/zacharie/.local/share/${name}"; })
      globals.dataFile
    );
  };
  inputFiles = builtins.catAttrs "name" (
    builtins.filter
      ({ name, value }: name != "default.nix" && name != "utils.nix")
      (utils.attrItems (builtins.readDir ./.))
  );
  inputFuncs = builtins.map (path: import ./${path}) inputFiles;
  inputs = builtins.map
    (func: func { inherit pkgs unstable lib; globals = globalsFinal; })
    inputFuncs;
in
{
  user = lib.mkMerge (
    [{
      xdg.dataFile = globals.dataFile;

      home.packages =
        (
          (builtins.concatLists (builtins.catAttrs "packages" inputs)) ++
          [ (pkgs.python3.withPackages (ps: (builtins.concatMap (x: x ps) (builtins.catAttrs "python-packages" inputs)))) ]
        )
      ;
      services = lib.mkMerge (builtins.catAttrs "services" inputs);
      programs = lib.mkMerge (builtins.catAttrs "programs" inputs);
    }] ++
    (builtins.map (input: removeAttrs input [ "packages" "python-packages" "services" "programs" "system" ]) inputs)

  );
  system = lib.mkMerge ((builtins.catAttrs "system" inputs) ++ [{
    fonts.packages = [ globals.font.package ];
  }]);
}
