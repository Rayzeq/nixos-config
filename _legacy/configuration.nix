{ pkgs, ... }:
{
  imports = [ ./hyprland/system.nix ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs = {
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "openssl-1.1.1w"
      ];
    };
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.tmp.cleanOnBoot = true;
  boot.kernel.sysctl."kernel.sysrq" = 502;

  # Firmware updates
  services.fwupd.enable = true;

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

  systemd.sleep.settings.Sleep.HibernateDelaySec = "1h";

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
    extraGroups = [ "wheel" "input" ];
    packages = with pkgs; [
      simple-scan
      vlc
      python3
      gimp3-with-plugins
      inkscape-with-extensions
      blender

      modrinth-app
      heroic
      wineWow64Packages.full
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

  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [
    gparted
    trashy
    kdePackages.kcalc
    unrar
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


  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "zacharie" ];
  systemd.coredump.extraConfig = "Storage=none";
}
