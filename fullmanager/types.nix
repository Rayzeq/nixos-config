{ lib }:
let
  inherit (lib) mkOptionType types isAttrs showOption showFiles getFiles foldl';
  inherit (lib.lists) head;
  inherit (lib.options) mergeEqualOption mergeOneOption;
in
rec {
  anythingWithLists = mkOptionType {
    name = "anythingWithLists";
    description = "anything with merged lists";
    descriptionClass = "noun";
    check = value: true;
    merge = loc: defs:
      let
        getType = value:
          if isAttrs value && lib.isStringLike value
          then "stringCoercibleSet"
          else builtins.typeOf value;

        # Returns the common type of all definitions, throws an error if they
        # don't have the same type
        commonType = foldl'
          (type: def:
            if getType def.value == type
            then type
            else throw "The option `${showOption loc}' has conflicting option types in ${showFiles (getFiles defs)}"
          )
          (getType (head defs).value)
          defs;

        mergeFunction = {
          # Recursive attribute set merge
          set = (types.attrsOf anythingWithLists).merge;

          # Package-like sets (single definition only)
          stringCoercibleSet = mergeOneOption;

          # Function content merging
          lambda = loc: defs: arg: anythingWithLists.merge
            (loc ++ [ "<function body>" ])
            (map
              (def: {
                file = def.file;
                value = def.value arg;
              })
              defs);

          # Concatenate lists
          list = loc: defs: builtins.concatLists (map (def: def.value) defs);
        }.${commonType} or mergeEqualOption; # Fallback for other types
      in
      mergeFunction loc defs;
  };
}
