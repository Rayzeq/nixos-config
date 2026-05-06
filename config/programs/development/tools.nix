{ pkgs, ... }: {
  hm.home.packages = with pkgs; [
    # Essentials
    gnumake
    clang
    gdb

    # Rust
    rustup

    # Java
    jetbrains.idea
  ];
}
