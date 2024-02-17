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

  cargoPatches = [
    ./sni.patch
    ./sni-click.patch
    ./max_width.patch
    ./custom_tooltips.patch
    # Custom popovers
    # The `#1` at the end of the url is here to force nixos to re-download the patch
    # when the remote repo is updated
    (pkgs.fetchpatch {
      url = "https://patch-diff.githubusercontent.com/raw/Rayzeq/eww/pull/1.patch#1";
      hash = "sha256-vSV8fYBOFzhBPlouxr34e13SeEw5NC53LLbI+pT8drA=";
    })
  ];

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
