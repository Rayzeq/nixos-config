{ nixpkgs, home-manager, lib, config, ... }:
let
  inherit (lib) mkOption mkOptionType types;
  cfg = config.hypr.land;

  hyprlandOptions = (lib.getOptions "${home-manager}/modules/services/window-managers/hyprland/default.nix").hyprland;
  hyprlandSystemOptions = (lib.getOptions "${nixpkgs}/nixos/modules/programs/wayland/hyprland.nix");

  luaDictType = with types; attrsOf (oneOf [ bool int float str (listOf str) attrs ]);
  monitorType = types.submodule {
    options = {
      output = mkOption { type = types.str; };
      mode = mkOption { type = types.str; };
      position = mkOption { type = types.str; };
      scale = mkOption { type = types.int; };
    };
  };
  bindType = mkOptionType {
    name = "bind";
    check = x:
      let
        len = lib.length x;
      in
      lib.isList x &&
      len >= 2 &&
      lib.isString (lib.elemAt x 0) &&
      lib.isString (lib.elemAt x 1) &&
      (len == 2 || (len == 3 && lib.isAttrs (lib.elemAt x 2)));
  };
  settingsType = mkOption {
    type = types.submodule {
      freeformType = types.attrsOf luaDictType;

      options = {
        monitor = mkOption { type = types.listOf monitorType; };
        bind = mkOption { type = types.listOf bindType; };
        window_rule = mkOption { type = types.listOf types.attrs; };
        layer_rule = mkOption { type = types.listOf types.attrs; };
        gesture = mkOption { type = types.listOf types.attrs; };
      };
    };
  };
in
{
  options.hypr.land = {
    inherit (hyprlandOptions) enable package;
    inherit (hyprlandSystemOptions) withUWSM;
    settings = settingsType;
  };

  config = lib.mkIf cfg.enable {
    lib = {
      hyprland.dispatchers =
        let
          arg = arg: if lib.isString arg then "\"${lib.replaceStrings ["\""]  ["\\\""] arg}\"" else toString arg;
        in
        {
          exec = command: "hl.dsp.exec_cmd(${arg command})";
          focus.workspace = workspace: "hl.dsp.focus({ workspace = ${arg workspace} })";
          window = {
            drag = "hl.dsp.window.drag()";
            resize = "hl.dsp.window.resize()";
            close = "hl.dsp.window.close()";
            float = action: "hl.dsp.window.float({ action = ${arg action} })";
            pin = action: "hl.dsp.window.pin({ action = ${arg action} })";
            fullscreen = mode: action: "hl.dsp.window.fullscreen({ mode = ${arg mode}, action = ${arg action} })";
            move.workspace = workspace: "hl.dsp.window.move({ workspace = ${arg workspace} })";
          };
        };
    };
    system.programs.hyprland = {
      inherit (cfg) enable package withUWSM;
    };
    hm.wayland.windowManager.hyprland = {
      inherit (cfg) enable package;
      settings = {
        inherit (cfg.settings) monitor window_rule layer_rule gesture device;
        config = (removeAttrs cfg.settings [ "monitor" "bind" "window_rule" "layer_rule" "gesture" "device" ]);
        bind = map (bind: { _args = [ (lib.elemAt bind 0) (lib.generators.mkLuaInline (lib.elemAt bind 1)) ] ++ (if lib.length bind == 3 then [ (lib.elemAt bind 2) ] else [ ]); }) cfg.settings.bind;
      };
    } // (lib.optionalAttrs cfg.withUWSM { systemd.enable = false; });
  };
}
