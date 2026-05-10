{ systemConfig, hmConfig, ... }: {
  user = {
    isNormalUser = true;
    description = "Zacharie";
    extraGroups = [ "wheel" ];
    hashedPasswordFile = systemConfig.age.secrets.password-zacharie.path;
  };
  system.age.identityPaths = [ "${hmConfig.home.homeDirectory}/.ssh/id_ed25519" ];

  nh.osFlake = "${hmConfig.xdg.configHome}/nixos";

  user.openssh.authorizedKeys.keys = [ (import ../../secrets/keys.nix).zacharie ];
  pam.u2f.keys.zacharie = [ "T0NEtAQt/GfQDBcwVP38eaCqJB/F0sz5G38Hl2UrfDgntonIp0wSiRHl4ZIgjR03qAnBxX8aO/8DPPzgIKiQjg==,+1Zu7GGqcP7gvxUgGhEtVOByh3wg6Lbpk6/RCRDtF+5UgoR3E7FF2xtwEGvqviURrbayFj26hIeaV71SUpRQqg==,es256,+presence" ];
}
