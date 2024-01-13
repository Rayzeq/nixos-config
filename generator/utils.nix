{
  attrItems = attrset: builtins.attrValues (
    builtins.mapAttrs
      (name: value: { inherit name value; })
      attrset
  );
}
