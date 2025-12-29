{ pkgs, ... }:
{
  imports = [ <home-manager/nixos> ./hardware-configuration.nix ./zacharie.nix ./hyprland/system.nix ./fullmanager ];

  nixpkgs = {
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "openssl-1.1.1w"
      ];
    };
    overlays = [
      (final: prev: {
        vencord = prev.vencord.overrideAttrs (oldAttrs: {
          patches = (oldAttrs.patches or [ ]) ++ [ ./mudaebot.patch ];
        });
        discord = prev.discord.override {
          withOpenASAR = true;
          withVencord = true;
        };
      })
    ];
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.tmp.cleanOnBoot = true;
  boot.kernel.sysctl."kernel.sysrq" = 502;

  # Firmware updates
  services.fwupd.enable = true;

  networking.hostName = "zacharie-ThinkPad";

  # Enable networking
  networking.networkmanager.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  zramSwap.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  # Enable the KDE Plasma Desktop Environment.
  services.desktopManager.plasma6.enable = true;
  environment.plasma6.excludePackages = with pkgs.kdePackages; [ elisa konsole kate akregator spectacle ];

  services.logind.settings.Login = {
    HandleLidSwitch = "hibernate";
    HandleLidSwitchExternalPower = "hibernate";
    HandlePowerKey = "ignore";
  };

  systemd.sleep.extraConfig = ''
    HibernateDelaySec=1h
  '';

  hardware.graphics.enable32Bit = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;
  # Auto-discovery of printers
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Enable sound with pipewire.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.zacharie = {
    isNormalUser = true;
    description = "Zacharie";
    extraGroups = [ "networkmanager" "wheel" "input" "dialout" ];
    packages = with pkgs; [
      simple-scan
      vlc
      python3
      gimp3-with-plugins
      inkscape-with-extensions
      blender
      discord

      mangohud
      modrinth-app
      heroic
      wineWowPackages.full
      winetricks

      # Rust
      rustup
      cargo-generate
      clang
      # Build essentials
      gnumake
      gdb
      # Other
      jetbrains.idea

      # Useful
      steam-run
    ];
  };
  environment.etc."ppp/options".text = "ipcp-accept-remote";

  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [
    git
    sublime-merge
    gparted
    zsh-syntax-highlighting
    zsh-autosuggestions
    zsh-powerlevel10k
    trashy
    lsd
    bat
    ripgrep
    kdePackages.kcalc
    unrar
    man-pages
    file
    piper
    htop
    dust
    zip
  ];

  programs.gamemode.enable = true;
  programs.kdeconnect.enable = true;
  services.ratbagd.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [ zsh ];
  programs.command-not-found.enable = true;

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "zacharie" ];
  systemd.coredump.extraConfig = "Storage=none";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
