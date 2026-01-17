lib:
let
  deferMerge = lib.mkOptionType {
    name = "deferMerge";
    description = "do not perform any merging. juste uses mkMerge";
    descriptionClass = "";
    merge = loc: defs: lib.mkMerge (map (def: def.value) defs);
  };
  recursiveMerge = lib.mkOptionType rec {
    name = "recursiveMerge";
    description = "recursively merges attrs, deduplicates identical scalars, then uses mkMerge.";

    merge = loc: defs:
      let
        values = map (d: d.value) defs;

        # Determine if we should recurse. 
        # We only recurse if ALL definitions are attribute sets, but NOT derivations.
        isBranch = v: lib.isAttrs v && !lib.isDerivation v;
      in
      if lib.all isBranch values then
        let
          allKeys = lib.concatMap lib.attrNames values;
          uniqueKeys = lib.unique allKeys;
        in
        lib.genAttrs uniqueKeys (key:
          merge (loc ++ [ key ]) (
            # using concatMap like a filterMap (which doesn't exists)
            builtins.concatMap
              (def:
                if lib.hasAttr key def.value then
                  [{ file = def.file; value = def.value.${key}; }]
                else
                  [ ]
              )
              defs
          )
        )
      else
        let
          uniqueValues = lib.unique values;
        in
        if builtins.length uniqueValues == 1 then
          builtins.head uniqueValues
        else
          lib.mkMerge uniqueValues;
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
      attrset;
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
    (hostname: host @ { stateVersion, specialArgs ? { }, modules ? [ ], ... }:
      lib.nixosSystem ({
        specialArgs = (withWarnings specialArgs) // {
          inherit nixpkgs home-manager;
          hostname = hostname;
        };
        modules = modules ++ [
          home-manager.nixosModules.home-manager
          ({ ... }: {
            system.stateVersion = stateVersion;
            home-manager.useGlobalPkgs = true;
          })
          ./hosts/${hostname}/hardware.nix
          ({ pkgs, config, ... }:
            let
              systemConfig = config;

              evalConfig = username: hmConfig: lib.evalModules {
                specialArgs = {
                  inherit nixpkgs home-manager pkgs systemConfig hmConfig;
                  lib = lib // { inherit getModules; getOptions = getOptions pkgs; };
                };
                modules = [
                  ({ config, ... }: {
                    options = {
                      system = lib.mkOption {
                        type = recursiveMerge;
                        default = { };
                        description = "Options to forward to NixOS";
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
                      hm.home.stateVersion = config.stateVersion.${hostname};
                    };
                  })
                  ./users/${username}.nix
                  ./hosts/${hostname}
                ]
                ++ (getModules ./modules [ ])
                ++ (getModules ./config [ ]);
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
              config = lib.mkMerge [
                {
                  home-manager.users = builtins.mapAttrs
                    (_: modules: modules.config.hm)
                    users;
                }
                (recursiveMerge.merge [ ] (lib.mapAttrsToList
                  (_: user: {
                    file = "manualMerge";
                    value = user.config.system;
                  })
                  users)
                )
              ];
            }
          )
        ];
      } // removeAttrs host [ "stateVersion" "specialArgs" "modules" ])
    )
    (removeAttrs hosts [ "nixpkgs" "home-manager" ]);
}
