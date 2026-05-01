{ pkgs, lib, ... }: {
  greetd = {
    enable = true;

    enableNumlock = true;
    useTextGreeter = true;
    settings = {
      default_session.command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --user-menu --user-menu-min-uid 1000 --user-menu-max-uid 1001 --cmd start-hyprland";
    };
  };
}
