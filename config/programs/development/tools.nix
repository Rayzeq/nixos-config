{ pkgs, ... }: {
  hm.home.packages = with pkgs; [
    # Essentials
    gnumake
    clang
    gdb

    # Python
    (python3.withPackages (ppkgs: with ppkgs; [
      # commonly used, especially in throwaway scripts
      requests
    ]))

    # Rust
    (symlinkJoin {
      name = "rustup-patched-completions";

      paths = [ rustup ];
      nativeBuildInputs = [ patch ];
      postBuild =
        let
          patchFile = writeText "fix-completions.patch" ''
            --- _rustup     2025-05-28 13:56:04.977723677 -0400
            +++ _rustup 2025-05-28 14:08:44.304529544 -0400
            @@ -23,16 +23,18 @@
             '--help[Print help]' \
             '-V[Print version]' \
             '--version[Print version]' \
            -'::+toolchain -- Release channel (e.g. +stable) or custom toolchain to set override:_default' \
            +'(+beta +nightly)+stable[use the stable toolchain]' \
            +'(+stable +nightly)+beta[use the beta toolchain]' \
            +'(+stable +beta)+nightly[use the nightly toolchain]' \
             ":: :_rustup_commands" \
             "*::: :->rustup" \
             && ret=0
                 case $state in
                 (rustup)
            -        words=($line[2] "''${words[@]}")
            +        words=($line[1] "''${words[@]}")
                     (( CURRENT += 1 ))
            -        curcontext="''${curcontext%:*:*}:rustup-command-$line[2]:"
            -        case $line[2] in
            +        curcontext="''${curcontext%:*:*}:rustup-command-$line[1]:"
            +        case $line[1] in
                         (install)
             _arguments "''${_arguments_options[@]}" : \
             '--profile=[]:PROFILE:(minimal default complete)' \
          '';
        in
        ''
          # Make normal file instead of symlink
          rm $out/share/zsh/site-functions/_rustup
          cp ${rustup}/share/zsh/site-functions/_rustup $out/share/zsh/site-functions/_rustup
          chmod +w $out/share/zsh/site-functions/_rustup
    
          patch $out/share/zsh/site-functions/_rustup < ${patchFile}
        '';
      meta = rustup.meta // {
        description = "Rust toolchain installer (with patched Zsh completions)";
      };
    })

    # Java
    jetbrains.idea
  ];
}
