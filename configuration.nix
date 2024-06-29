{ config, pkgs, ... }:

# The unstable channel for some packages
let
  unstable = import <nixos-unstable> {
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "nix-2.16.2" # needed by nixd
      ];
    };
  };
in
{
  _module.args.unstable = unstable;
  imports = [ <home-manager/nixos> ./hardware-configuration.nix ./zacharie.nix ./hyprland/system.nix ./tuigreet.nix ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.tmp.cleanOnBoot = true;

  networking.hostName = "zacharie-ThinkPad";

  # Enable networking
  networking.networkmanager.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

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
  environment.plasma6.excludePackages = with pkgs.libsForQt5; [ elisa konsole ];

  services.logind.extraConfig = ''
    HandleLidSwitch=hibernate
    HandleLidSwitchExternalPower=hibernate
  '';

  systemd.sleep.extraConfig = ''
    HibernateDelaySec=1h
  '';

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "fr";
    variant = "oss";
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

  users.users.zacharie = {
    isNormalUser = true;
    description = "Zacharie";
    extraGroups = [ "networkmanager" "wheel" "input" ];
    packages = with pkgs; [
      vlc
      obsidian
      python3
      unstable.mission-center
      gimp-with-plugins
      (discord.override { withOpenASAR = true; withVencord = true; })

      mangohud
      gamemode
      prismlauncher

      # Rust
      rustup
      clang

      # Useful
      steam-run
      # IUT
      openfortivpn
    ];
  };
  environment.etc."ppp/options".text = "ipcp-accept-remote";

  # Allow unfree packages (like Sublime Merge)
  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0" # obsidian need this
  ];

  nixpkgs.overlays = [
    (self: super: {
      vencord = unstable.vencord.overrideAttrs (oldAttrs: {
        patches = (oldAttrs.patches or [ ]) ++ [ ./mudaebot.patch ];
      });
    })
    (self: super: {
      wpa_supplicant = super.wpa_supplicant.overrideAttrs (oldAttrs: {
        extraConfig = oldAttrs.extraConfig + ''
          CONFIG_WEP=y
        '';
      });
    })
    (self: super: {
      trashy = super.trashy.overrideAttrs (oldAttrs: {
        preFixup = ''
          installShellCompletion --cmd trash \
            --bash <($out/bin/trash completions bash) \
            --fish <($out/bin/trash completions fish) \
            --zsh <($out/bin/trash completions zsh | grep -v ">trashy") \
        '';
      });
    })
  ];

  programs.firefox.enable = true;

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
    libsForQt5.kcalc
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
