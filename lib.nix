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

  targets = lib.mapAttrsToList (name: _: lib.removeSuffix ".nix" name) (lib.readDir ./targets);
  hosts = lib.filter
    (x: x != "")
    (lib.uniqueStrings (map (name: lib.last (lib.split "@" name)) targets));
  getUsers = host: lib.filter
    (x: x != "")
    (lib.uniqueStrings (map
      (name:
        let
          pair = lib.split "@" name;
          userHost = lib.last pair;
        in
        if userHost == host || userHost == "" then
          lib.head pair
        else
          ""
      )
      targets
    ));
  getImportPaths = path:
    if lib.pathExists (path + ".nix") then
      [ (path + ".nix") ]
    else if lib.pathExists path then
      [ path ]
    else
      [ ]
  ;

  importRecursive = arg:
    let
      argType = lib.typeOf arg;
      fileType = lib.readFileType arg;
    in
    if argType == "path" then
      if fileType == "directory" then
        lib.concatLists
          (lib.mapAttrsToList (name: _: importRecursive (arg + "/${name}")) (lib.readDir arg))
      else if fileType == "regular" && lib.hasSuffix ".nix" arg then
        [ arg ]
      else
        [ ]
    else if argType == "list" then
      lib.concatMap importRecursive arg
    else if argType == "set" then
      imports: lib.filter (file: !(lib.any (exclude: file == exclude || lib.path.hasPrefix exclude file) arg.exclude)) (importRecursive imports)
    else
      abort "Unsupported import type"
  ;

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
      module = import path rec {
        inherit lib pkgs;
        config = { };
        options = { };
        utils = import "${pkgs}/nixos/lib/utils.nix" { inherit lib config pkgs; };
      };
    in
    getAttrIfUniq module.options 2;
  deferOption = base: lib.mkOption
    {
      type = deferMerge;
    }
  // (lib.optionalAttrs (base ? apply) { apply = base.apply; })
  // (lib.optionalAttrs (base ? default) { default = base.default; })
  // (lib.optionalAttrs (base ? defaultText) { defaultText = base.defaultText; })
  // (lib.optionalAttrs (base ? example) { example = base.example; })
  // (lib.optionalAttrs (base ? description) { description = base.description; })
  // (lib.optionalAttrs (base ? relatedPackages) { relatedPackages = base.relatedPackages; })
  // (lib.optionalAttrs (base ? visible) { visible = base.visible; })
  // (lib.optionalAttrs (base ? readOnly) { readOnly = base.readOnly; });
in
{
  nixosSystems = { nixpkgs, home-manager, modules ? [ ] }: lib.genAttrs hosts
    (hostname: lib.nixosSystem {
      specialArgs = { inherit nixpkgs home-manager; };
      modules = modules ++ [
        ./targets/${"@" + hostname}/hardware.nix
        ({ pkgs, config, ... }:
          let
            systemConfig = config;

            evalConfig = username: hmConfig: lib.evalModules {
              specialArgs = {
                inherit nixpkgs home-manager pkgs systemConfig hmConfig hostname username;
                lib = lib // { import = importRecursive; getOptions = getOptions pkgs; defer = deferOption; };
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

                    user = lib.mkOption {
                      type = deferMerge;
                      default = { };
                      description = "Options to forward to users.users.<username>";
                    };

                    architecture = lib.mkOption {
                      type = lib.types.str;
                    };
                    stateVersion = lib.mkOption {
                      type = with lib.types; attrsOf str;
                    };
                  };
                  config = {
                    system = {
                      nixpkgs.system = config.architecture;
                      system.stateVersion = config.stateVersion.system;
                      home-manager.useGlobalPkgs = true;
                      users.users.${username} = config.user;
                    };
                    hm.home.stateVersion = config.stateVersion.${username};
                  };
                })
              ]
              ++ (getImportPaths ./targets/${username + "@"})
              ++ (getImportPaths ./targets/${"@" + hostname})
              ++ (getImportPaths ./targets/${username + "@" + hostname})
              ++ (importRecursive ./options);
            };
            users = lib.genAttrs
              (getUsers hostname)
              (username: evalConfig username config.home-manager.users.${username});
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
    });
}
