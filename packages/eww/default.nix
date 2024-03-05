{ pkgs, lib }:
with import <nixpkgs>
{
  overlays = [
    (import (fetchTarball "https://github.com/oxalica/rust-overlay/archive/master.tar.gz"))
  ];
};
let
  rustPlatform = makeRustPlatform {
    cargo = rust-bin.stable.latest.minimal;
    rustc = rust-bin.stable.latest.minimal;
  };
in
rustPlatform.buildRustPackage rec {
  pname = "eww";
  version = "0.5.0";

  src = pkgs.fetchFromGitHub {
    owner = "elkowar";
    repo = "eww";
    rev = "7bfd47eb8130f02f2a8f695c255df2f5302636b4";
    hash = "sha256-CCwOEyCtn/y9IxhY64OTr1iDyPl2XjrF2u93Z2ex56E=";
  };

  cargoPatches = [
    ./custom-popover.patch
    ./string-truncation.patch
    ./tray3.patch
  ];

  cargoHash = "sha256-RQhEAdUHVRGrKVgVZ4v6dSW6v1UbPmWHKI59/XGn/S8=";

  nativeBuildInputs = with pkgs; [ pkg-config wrapGAppsHook installShellFiles ];

  buildInputs = with pkgs; [ gtk3 librsvg gtk-layer-shell libdbusmenu libdbusmenu-gtk3 ];

  buildNoDefaultFeatures = true;
  buildFeatures = [ "wayland" ];

  cargoBuildFlags = [ "--bin" "eww" ];

  cargoTestFlags = cargoBuildFlags;

  preFixup = ''
    installShellCompletion --cmd eww \
      --bash <($out/bin/eww shell-completions --shell bash) \
      --fish <($out/bin/eww shell-completions --shell fish) \
      --zsh <($out/bin/eww shell-completions --shell zsh) \
  '';
}
