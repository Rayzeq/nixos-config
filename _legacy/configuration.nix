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
    overlays = [
      (final: prev: {
        rofi-games = prev.rofi-games.overrideAttrs (oldAttrs: {
          buildInputs = oldAttrs.buildInputs ++ [ pkgs.sqlite ];

          src = pkgs.fetchFromGitHub {
            owner = "Rolv-Apneseth";
            repo = "rofi-games";
            rev = "a8c6ef50fbb60fa29508ecc88d5736c0fd89ade1";
            hash = "sha256-LwzlBjRh9YdUGBl9+L3Vdetmy7lUdAIvjKvp8hSebvY=";
          };

          patches = oldAttrs.patches ++ [ ./a.patch ];

          cargoDeps = pkgs.rustPlatform.importCargoLock {
            lockFile = ./Cargo.lock;
            outputHashes = {
              "lib_game_detector-0.0.28" = "sha256-f8DH+cSaN4u/ugLJuyNDsACyihde52X7s4hdlV8nT5U=";
            };
          };
        });
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

  services.logind.settings.Login = {
    HandleLidSwitch = "hibernate";
    HandleLidSwitchExternalPower = "hibernate";
    HandlePowerKey = "ignore";
  };

  systemd.sleep.settings.Sleep.HibernateDelaySec = "1h";

  hardware.graphics.enable32Bit = true;

  # Enable sound with pipewire.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [
    gparted
    trashy
    unrar
    piper
    htop
    dust
    zip
  ];

  programs.kdeconnect.enable = true;
  services.ratbagd.enable = true;

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "zacharie" ];
  systemd.coredump.settings.Coredump.Storage = "none";
}
