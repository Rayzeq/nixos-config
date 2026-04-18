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

  getModules = folder:
    let
      modules = lib.concatLists (lib.mapAttrsToList
        (name: type:
          let path = "${folder}/${name}";
          in if type == "regular" && lib.hasSuffix ".nix" name then
            [ path ]
          else if type == "directory" then
            getModules path
          else [ ]
        )
        (builtins.readDir folder)
      );
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
        options = { };
      };
    in
    getAttrIfUniq module.options 2;
in
{
  nixosSystems = hosts @ { nixpkgs, home-manager, commonModules ? [ ], ... }: lib.mapAttrs
    (hostname: host @ { stateVersion, specialArgs ? { }, modules ? [ ], ... }:
      lib.nixosSystem ({
        inherit specialArgs;
        modules = modules ++ commonModules ++ [
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
                  inherit nixpkgs home-manager pkgs systemConfig hmConfig hostname;
                  lib = lib // { getOptions = getOptions pkgs; };
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
                ++ (getModules ./modules)
                ++ (getModules ./config);
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
                  networking.hostName = hostname;
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
    (removeAttrs hosts [ "nixpkgs" "home-manager" "commonModules" ]);
}
