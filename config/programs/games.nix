{ pkgs, ... }: {
  system.programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  hm.programs.prismlauncher = {
    enable = true;
    package = pkgs.prismlauncher.override { jdks = with pkgs; [ jdk25 jdk21 jdk17 ]; };
  };
  hm.home.packages = with pkgs; [
    heroic
  ];
}
