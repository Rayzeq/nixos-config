{ config, pkgs, ... }:

# The unstable channel for some packages
let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in
{
  imports = [ ./hardware-configuration.nix ./zacharie.nix ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "zacharie-ThinkPad";

  # Enable networking
  networking.networkmanager.enable = true;

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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  services.xserver.excludePackages = with pkgs; [ xterm ];

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.displayManager.sddm.autoNumlock = true;
  services.xserver.desktopManager.plasma5.enable = true;
  environment.plasma5.excludePackages = with pkgs.libsForQt5; [ elisa ];

  # Configure keymap in X11
  services.xserver = {
    layout = "fr";
    xkbVariant = "oss";
  };

  hardware.opengl.driSupport32Bit = true;

  # Configure console keymap
  console.keyMap = "fr";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
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

  nixpkgs.overlays = [
    (final: prev: {
      mission-center = unstable.mission-center.overrideAttrs (old: {
        src = prev.fetchFromGitLab {
          owner = "mission-center-devs";
          repo = "mission-center";
          rev = "v0.3.2";
          hash = "sha256-KuaVivW/i+1Pw6ShpvBYbwPMUHsEJ7FR80is0DBMbXM=";
        };

        cargoDeps = prev.symlinkJoin {
          name = "cargo-vendor-dir";
          paths = [
            (prev.rustPlatform.importCargoLock {
              lockFile = ./mission-center/Cargo.lock;
              outputHashes = {
                "pathfinder_canvas-0.5.0" = "sha256-k2Sj69hWA0UzRfv91aG1TAygVIuOX3gmipcDbuZxxc8=";
              };
            })
            (prev.rustPlatform.importCargoLock {
              lockFile = ./mission-center/gatherer-Cargo.lock;
            })
          ];
        };
      });
    })
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.zacharie = {
    isNormalUser = true;
    description = "Zacharie";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      barrier
      vlc
      obsidian
      python3
      mission-center
      (opera.override { proprietaryCodecs = true; })
      (discord.override { withOpenASAR = true; withVencord = true; vencord = (vencord.overrideAttrs { patches = vencord.patches ++ [ ./mudaebot.patch ]; }); })

      mangohud
      gamemode
      prismlauncher
      # Useful
      steam-run
      # IUT
      openfortivpn
      networkmanager-fortisslvpn
      gnome.networkmanager-fortisslvpn
    ];
  };
  environment.etc."ppp/options".text = "ipcp-accept-remote";

  # Allow unfree packages (like Sublime Text)
  nixpkgs.config.allowUnfree = true;

  # Sublime Text needs this
  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1w"
  ];

  environment.systemPackages = with pkgs; [
    git
    sublime-merge
    sublime4
    gparted
    unstable.nixd
    nixpkgs-fmt
    nodejs
    zsh-syntax-highlighting
    zsh-autosuggestions
    zsh-powerlevel10k
    meslo-lgs-nf
    trashy
    lsd
    bat
    ripgrep
  ];

  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [ "git" "sublime" "python" "command-not-found" "rust" ];
      customPkgs = with pkgs; [ nix-zsh-completions zsh-powerlevel10k ];
    };
    promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
  };
  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [ zsh ];

  fonts.fonts = with pkgs; [
    fira-code
  ];

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
