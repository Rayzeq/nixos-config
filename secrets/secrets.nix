let
  keys = import ./keys.nix;
in
{
  "password-zacharie.age".publicKeys = [ keys.zacharie ];
}
