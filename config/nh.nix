{ lib, ... }: {
  nh = {
    enable = lib.mkDefault true;
    osFlake = "/home/zacharie/.config/nixos";
  };
}
