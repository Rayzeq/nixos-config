lib:
let
  deferMerge = lib.mkOptionType {
    name = "deferMerge";
    description = "do not perform any merging. juste uses mkMerge";
    descriptionClass = "";
    merge = loc: defs: lib.mkMerge (map (def: def.value) defs);
  };
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

  getAttrIfUniq = attrset: max_rec:
    let
      values = builtins.attrValues attrset;
    in
    if (builtins.length values) == 1 then
      if max_rec == 1 then
        builtins.head values
      else
        getAttrIfUniq (builtins.head values) (max_rec - 1)
    else
      values;
  getOptions = pkgs: path:
    let
      module = import path {
        inherit lib pkgs;
        config = { };
      };
    in
    getAttrIfUniq module.options 2;

  withWarnings = specialArgs:
    lib.warnIf (specialArgs ? hostname) "Don't put `hostname` in extraArgs"
      lib.warnIf
      (specialArgs ? nixpkgs) "Don't put `nixpkgs` in extraArgs"
      lib.warnIf
      (specialArgs ? home-manager) "Don't put `home-manager` in extraArgs"
      specialArgs;
in
{
  nixosSystems = hosts @ { nixpkgs, home-manager, ... }: lib.mapAttrs
    (name: host @ { stateVersion, specialArgs ? { }, modules ? [ ], ... }:
      lib.nixosSystem ({
        specialArgs = (withWarnings specialArgs) // {
          inherit nixpkgs home-manager;
          hostname = name;
        };
        modules = modules ++ [
          home-manager.nixosModules.home-manager
          ({ ... }: {
            system.stateVersion = stateVersion;
            home-manager.useGlobalPkgs = true;
          })
          ./hosts/${name}/hardware.nix
          ({ pkgs, config, ... }:
            let
              systemConfig = config;

              globals = import ./config/globals.nix { inherit pkgs; self = globalsFinal; };
              globalsFinal = globals;

              evalConfig = username: hmConfig: lib.evalModules {
                specialArgs = {
                  inherit nixpkgs home-manager pkgs globals systemConfig hmConfig;
                  lib = lib // { inherit getModules; getOptions = getOptions pkgs; };
                };
                modules = [
                  ({ config, ... }: {
                    options = {
                      system = lib.mkOption {
                        type = deferMerge;
                        default = { };
                        description = "Options to forward to NixOS";
                      };

                      mergedSystem = lib.mkOption {
                        type = deferMerge;
                        default = { };
                        description = "Options to forward to NixOS, and merged between each users";
                      };

                      hm = lib.mkOption {
                        type = deferMerge;
                        default = { };
                        description = "Options to forward to Home Manager";
                      };

                      stateVersion = lib.mkOption {
                        type = with lib.types; attrsOf str;
                      };
                    };
                    config = {
                      hm.home.stateVersion = config.stateVersion.${name};
                    };
                  })
                  ./users/${username}.nix
                ]
                ++ (getModules ./modules [ "lib.nix" ])
                ++ (getModules ./config [ "globals.nix" ]);
              };
              users = lib.mapAttrs'
                (filename: _:
                  let
                    username = lib.removeSuffix ".nix" filename;
                  in
                  lib.nameValuePair username (evalConfig username config.home-manager.users.${username})
                )
                (builtins.readDir ./users);
            in
            {
              config = lib.mkMerge (
                (lib.mapAttrsToList
                  (username: modules: lib.mkMerge [
                    {
                      home-manager.users.${username} = modules.config.hm;
                    }
                    modules.config.mergedSystem
                  ])
                  users
                ) ++ [
                  # the non-merged system config should be the same for every user
                  ((builtins.head (builtins.attrValues users)).config.system)
                ]
              );
            }
          )
        ];
      } // removeAttrs host [ "stateVersion" "specialArgs" "modules" ])
    )
    (removeAttrs hosts [ "nixpkgs" "home-manager" ]);
}
