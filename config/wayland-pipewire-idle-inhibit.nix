{ lib, ... }: {
  wayland-pipewire-idle-inhibit.enable = lib.mkDefault true;
}
