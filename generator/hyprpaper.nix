{ unstable, lib, globals, ... }:
let
  config = import ../configuration/hyprpaper.nix {
    inherit globals;
  };
in
if config.enable then {
  packages = [ unstable.hyprpaper ];

  xdg.configFile."hypr/hyprpaper.conf".text = (lib.concatStrings
    (builtins.map
      (value: "preload=" + builtins.toString value + "\n")
      config.preload
    )
  ) + ("wallpaper=" + config.wallpaper.screen + "," + config.wallpaper.file);

  systemd.user.services.hyprpaper = {
    Unit = {
      Description = "Wallpaper daemon";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${unstable.hyprpaper}/bin/hyprpaper";
      Restart = "on-failure";
    };

    Install = { WantedBy = [ "graphical-session.target" ]; };
  };
} else { }
