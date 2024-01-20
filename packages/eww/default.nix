{ pkgs, lib }:
pkgs.rustPlatform.buildRustPackage rec {
  pname = "eww";
  version = "unstable-20-12-2023";

  src = pkgs.fetchFromGitHub {
    owner = "elkowar";
    repo = "eww";
    rev = "65d622c81f2e753f462d23121fa1939b0a84a3e0";
    hash = "sha256-MR91Ytt9Jf63dshn7LX64LWAVygbZgQYkcTIKhfVNXI=";
  };

  cargoPatches = [ ./sni.patch ./sni-click.patch ./max_width.patch ./custom_tooltips.patch ./custom_popover.patch ];

  cargoHash = "sha256-toJsCFOIVs8XhyPGDu10UIbf5+gCRz6hpwsRE/+Y+jw=";

  nativeBuildInputs = with pkgs; [ pkg-config wrapGAppsHook ];

  buildInputs = with pkgs; [ gtk3 librsvg gtk-layer-shell libdbusmenu libdbusmenu-gtk3 ];

  buildNoDefaultFeatures = true;
  buildFeatures = [ "wayland" ];

  cargoBuildFlags = [ "--bin" "eww" ];

  cargoTestFlags = cargoBuildFlags;

  # requires unstable rust features
  RUSTC_BOOTSTRAP = 1;
}
