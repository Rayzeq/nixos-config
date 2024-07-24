{ config, pkgs, ... }:
{
  imports = [ <home-manager/nixos> ./hardware-configuration.nix ./zacharie.nix ./hyprland/system.nix ./tuigreet.nix ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    (final: prev: {
      vencord = prev.vencord.overrideAttrs (oldAttrs: {
        patches = (oldAttrs.patches or [ ]) ++ [ ./mudaebot.patch ];
      });
      discord = prev.discord.override {
        withOpenASAR = true;
        withVencord = true;
      };
      wpa_supplicant = prev.wpa_supplicant.overrideAttrs (oldAttrs: {
        extraConfig = oldAttrs.extraConfig + ''
          CONFIG_WEP=y
        '';
      });
    })
  ];

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
  environment.plasma6.excludePackages = with pkgs.kdePackages; [ elisa konsole ];

  services.logind.extraConfig = ''
    HandleLidSwitch=hibernate
    HandleLidSwitchExternalPower=hibernate
  '';

  systemd.sleep.extraConfig = ''
    HibernateDelaySec=1h
  '';

  hardware.graphics.enable32Bit = true;

  # Configure console keymap
  console.keyMap = "fr";

  # Enable CUPS to print documents.
  services.printing.enable = true;
  # Auto-discovery of printers
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  users.users.zacharie = {
    isNormalUser = true;
    description = "Zacharie";
    extraGroups = [ "networkmanager" "wheel" "input" "dialout" ];
    packages = with pkgs; [
      simple-scan
      vlc
      obsidian
      python3
      mission-center
      gimp-with-plugins
      discord

      mangohud
      gamemode
      prismlauncher

      # Rust
      rustup
      clang
      # Build essentials
      gnumake
      gdb

      # Useful
      steam-run
      # IUT
      openfortivpn
    ];
  };
  environment.etc."ppp/options".text = "ipcp-accept-remote";

  programs.firefox.enable = true;
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
    du-dust
  ];

  programs.gamemode.enable = true;
  programs.kdeconnect.enable = true;
  services.ratbagd.enable = true;

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [ zsh ];

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "zacharie" ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
