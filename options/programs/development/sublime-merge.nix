{ lib, pkgs, config, ... }:
let
  inherit (lib) mkOption mkEnableOption mkPackageOption mkIf;
  cfg = config.sublime-merge;

  configDirectory = "sublime-merge/Packages";
  jsonFormat = pkgs.formats.json { };

  unzip = archive: filename: pkgs.runCommand "unzip"
    { nativeBuildInputs = [ pkgs.unzip ]; }
    ''unzip -p "${archive}" "${filename}" > "$out"'';
  patcher = pkgs.writers.writePython3 "merge-patcher"
    {
      libraries = [ pkgs.python3Packages.json5 ];
      flakeIgnore = [ "E501" ];
    }
    (builtins.readFile ./merge-patcher.py);
  patch = type: file: pkgs.runCommand "merge-patch" { }
    ''${patcher} ${type} "${file}" "$out"'';
  builtinThemePackage = "${cfg.package.unwrapped}/Packages/Theme - Merge.sublime-package";

  schemeFilename = "Monokai.sublime-color-scheme";
  scheme = unzip "${cfg.package.unwrapped}/Packages/Color Scheme - Default.sublime-package" schemeFilename;

  # We replace Merge.sublime-theme, so we have to copy it with a new name
  mergBaseFilename = "Merge Base.sublime-theme";
  mergBase = unzip builtinThemePackage "Merge.sublime-theme";

  # Copy of Merge Dark.sublime-theme but extending the copied Merge.sublime-theme
  mergDarkBaseFilename = "Merge Dark Base.sublime-theme";
  mergDarkBase = patch "dark-base" (unzip builtinThemePackage "Merge Dark.sublime-theme");

  patchedTheme = patch "patch-theme" ./MergeAdaptive.sublime-theme;

  copiedFiles = [ "Commit Message - Merge.sublime-settings" "File Mode - Merge.sublime-settings" "Git Output - Merge.sublime-settings" ];
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
      # Not in Theme - Merge.sublime-package for some reason
      "${configDirectory}/User/Diff - Merge.sublime-settings".source = jsonFormat.generate "sublime-merge-diff-settings" { color_scheme = schemeFilename; };
      "${configDirectory}/Theme - Merge/${mergBaseFilename}".source = mergBase;
      "${configDirectory}/Theme - Merge/${mergDarkBaseFilename}".source = mergDarkBase;
      "${configDirectory}/Theme - Merge/Merge.sublime-theme".source = patchedTheme;
    } // lib.genAttrs' copiedFiles (filename: lib.nameValuePair
      "${configDirectory}/User/${filename}"
      { source = patch "replace-scheme" (unzip builtinThemePackage filename); }
    );
  };
}
