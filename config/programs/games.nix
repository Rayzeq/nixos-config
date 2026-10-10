{ pkgs, ... }: {
  system.programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  hm.programs.prismlauncher.enable = true;
  hm.home.packages = with pkgs; [
    heroic
  ];
}
