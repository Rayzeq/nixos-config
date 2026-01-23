{ lib, ... }: {
  cliphist.enable = lib.mkDefault true;
  wayland-pipewire-idle-inhibit.enable = lib.mkDefault true;
}
