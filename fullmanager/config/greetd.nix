{ pkgs, ... }: {
  greetd = {
    enable = true;
    useTextGreeter = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --user-menu --user-menu-min-uid 1000 --user-menu-max-uid 1001 --cmd Hyprland";
        user = "greeter";
      };
    };
  };
}
