lib: {
  nixosSystems = hosts @ { nixpkgs, home-manager, ... }: lib.mapAttrs
    (name: host @ { stateVersion, specialArgs ? { }, modules ? [ ], ... }:
      let
        withWarnings = specialArgs:
          lib.warnIf (specialArgs ? hostname) "Don't put `hostname` in extraArgs"
            lib.warnIf
            (specialArgs ? nixpkgs) "Don't put `nixpkgs` in extraArgs"
            lib.warnIf
            (specialArgs ? home-manager) "Don't put `home-manager` in extraArgs"
            specialArgs;
      in
      lib.nixosSystem ({
        specialArgs = (withWarnings specialArgs) // {
          inherit nixpkgs home-manager;
          hostname = name;
        };
        modules = modules ++ [
          ({ ... }: {
            system.stateVersion = stateVersion;
          })
          ./hosts/${name}/hardware.nix
        ];
      } // removeAttrs host [ "stateVersion" "specialArgs" "modules" ])
    )
    (removeAttrs hosts [ "nixpkgs" "home-manager" ]);
}
