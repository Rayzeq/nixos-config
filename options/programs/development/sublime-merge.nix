{ lib, pkgs, config, ... }:
let
  inherit (lib) mkOption mkEnableOption mkPackageOption mkIf;
  cfg = config.sublime-merge;

  configDirectory = "sublime-merge/Packages";
  jsonFormat = pkgs.formats.json { };

  unzip = archive: filename: pkgs.runCommand "unzip"
    { nativeBuildInputs = [ pkgs.unzip ]; }
    ''unzip -p "${archive}" "${filename}" > "$out"'';
  patcher = pkgs.writers.writePython3 "patcher"
    {
      libraries = [ pkgs.python3Packages.json5 ];
      flakeIgnore = [ "E501" ];
    }
    (builtins.readFile ./merge-patcher.py);
  builtinThemePackage = "${cfg.package.unwrapped}/Packages/Theme - Merge.sublime-package";

  theme-source = pkgs.fetchFromGitHub {
    owner = "Resike";
    repo = "Merge-Monokai-Theme";
    rev = "master";
    hash = "sha256-RIXM6V408B3u9VACoRh+6Tc/IKb1/sh7IRJl7HBs3oE=";
  };

  schemeFilename = "Monokai.sublime-color-scheme";
  scheme = unzip "${cfg.package.unwrapped}/Packages/Color Scheme - Default.sublime-package" schemeFilename;

  # We replace Merge.sublime-theme, so we have to copy it with a new name
  mergBaseFilename = "Merge Base.sublime-theme";
  mergBase = unzip builtinThemePackage "Merge.sublime-theme";

  # Copy of Merge Dark.sublime-theme but extending the copied Merge.sublime-theme
  mergDarkBaseFilename = "Merge Dark Base.sublime-theme";
  mergDarkBase = pkgs.runCommand "patch-merge-dark-base" { }
    ''${patcher} dark-base "${mergBaseFilename}" "${unzip builtinThemePackage "Merge Dark.sublime-theme"}" "$out"'';

  patchedTheme = pkgs.runCommand "patch-merge-theme" { }
    ''${patcher} patch-theme "${theme-source}/Monokai.sublime-theme" "$out"'';

  copiedFiles = [ "Commit Message - Monokai.sublime-settings" "Diff - Monokai.sublime-settings" "File Mode - Monokai.sublime-settings" ];
in
{
  options.sublime-merge = {
    enable = mkEnableOption "Sublime Merge";
    package = mkPackageOption pkgs "sublime-merge" { };

    settings = mkOption {
      type = jsonFormat.type;
      default = { };
      description = ''
        Sublime Merge's user settings.
      '';
    };
  };

  config.hm = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    xdg.configFile = {
      "${configDirectory}/User/Preferences.sublime-settings".source = jsonFormat.generate "sublime-merge-settings" cfg.settings;

      "${configDirectory}/User/${schemeFilename}".source = scheme;
      "${configDirectory}/User/Widget - Merge.hidden-color-scheme".source = ./Widget-Merge.hidden-color-scheme;
      "${configDirectory}/User/Git Output - Merge.sublime-settings".source = jsonFormat.generate "sublime-merge-git-output-settings" { color_scheme = schemeFilename; };
      "${configDirectory}/Theme - Merge/${mergBaseFilename}".source = mergBase;
      "${configDirectory}/Theme - Merge/${mergDarkBaseFilename}".source = mergDarkBase;
      "${configDirectory}/Theme - Merge/Merge.sublime-theme".source = patchedTheme;
    } // lib.genAttrs' copiedFiles (x: lib.nameValuePair
      "${configDirectory}/User/${lib.replaceStrings [ "Monokai" ] [ "Merge" ] x}"
      { source = "${theme-source}/${x}"; }
    );
  };
}
