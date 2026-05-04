{ lib, ... }:
{
  home-manager.users.zacharie = { config, ... }: {
    services.playerctld.enable = true;
  };
}
