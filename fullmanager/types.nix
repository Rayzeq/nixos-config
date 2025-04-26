{ lib }:
{
  deferMerge = lib.mkOptionType {
    name = "deferMerge";
    description = "do not perform any merging. juste uses mkMerge";
    descriptionClass = "";
    merge = loc: defs: lib.mkMerge (map (def: def.value) defs);
  };
}
