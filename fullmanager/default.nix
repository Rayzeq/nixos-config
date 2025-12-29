{ lib, pkgs, ... }:
let
  inherit (lib) evalModules mkOption;
  customTypes = import ./types.nix { inherit lib; };

  globals = import ./config/globals.nix { inherit pkgs; self = globalsFinal; };
  globalsFinal = globals;

  getModules = folder: excludes:
    let
      dirContents = builtins.readDir folder;
      names = builtins.attrNames dirContents;
      filteredNames = builtins.filter (name: !(builtins.elem name excludes)) names;

      modules = map
        (name:
          let
            type = dirContents.${name};
            path = "${folder}/${name}";
          in
          if type == "regular" && lib.hasSuffix ".nix" name then
            path
          else if type == "directory" then
            let
              subDirContents = builtins.readDir path;
              hasDefault = builtins.elem "default.nix" (builtins.attrNames subDirContents);
            in
            if hasDefault then
              path
            else null
          else null
        )
        filteredNames;
      nonNullModules = builtins.filter (x: x != null) modules;
    in
    nonNullModules;

  fullmanager = evalModules {
    specialArgs = { inherit pkgs lib globals; };
    modules = [
      {
        options = {
          system = mkOption {
            type = customTypes.deferMerge;
            default = { };
            description = "Options to forward to NixOS";
          };

          hm = mkOption {
            type = customTypes.deferMerge;
            default = { };
            description = "Options to forward to Home Manager";
          };
        };
      }
    ]
    ++ (getModules ./modules [ "types.nix" ])
    ++ (getModules ./config [ "globals.nix" ]);
  };
in
{
  config = lib.mkMerge [
    (fullmanager.config.system or { })
    {
      home-manager.users.root = fullmanager.config.hm or { };
      home-manager.users.zacharie = fullmanager.config.hm or { };
    }
  ];
}
