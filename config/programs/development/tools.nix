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
    rustup

    # Java
    jetbrains.idea
  ];
}
