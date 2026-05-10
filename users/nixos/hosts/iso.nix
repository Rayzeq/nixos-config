{ nixpkgs, pkgs, lib, hmConfig, ... }: {
  hm.home.stateVersion = nixpkgs.lib.trivial.release;

  hm.home.packages = [
    (
      let
        public_key = pkgs.writeText "public-key" (import ../../../secrets/keys.nix).zacharie;
        private_key = pkgs.writeText "private-key" (lib.readFile "/home/zacharie/.ssh/id_ed25519");
      in
      pkgs.writeShellScriptBin "quick-install" ''
        set -euo pipefail

        if (( $# < 2 )); then
          >&2 echo "2 arguments expected, $# given"
          exit 1
        fi

        hostname=$1
        username=$2
        tmp_config=/tmp/config

        if [[ $1 = "--no-disk" ]]; then
          shift 1
        fi

        if [ ! -d "$tmp_config" ]; then
          cp -r "${builtins.path { path = ../../..; }}" $tmp_config
          chmod --recursive +w $tmp_config
        fi

        mkdir -p $tmp_config/hosts/$hostname/
        nixos-generate-config --no-filesystems --show-hardware-config > $tmp_config/hosts/$hostname/hardware.nix

        mkdir -p "${hmConfig.home.homeDirectory}/.ssh"
        cp "${public_key}" "${hmConfig.home.homeDirectory}/.ssh/id_ed25519.pub"
        cp "${private_key}" "${hmConfig.home.homeDirectory}/.ssh/id_ed25519"
        chmod 644 "${hmConfig.home.homeDirectory}/.ssh/id_ed25519.pub"
        chmod 600 "${hmConfig.home.homeDirectory}/.ssh/id_ed25519"

        sudo ${pkgs.disko}/bin/disko --mode destroy,format,mount --flake "$tmp_config#$hostname"

        install_location=/mnt

        sudo mkdir -p "$install_location/home/$username/.config"
        sudo mkdir -p "$install_location/home/$username/.ssh"

        sudo cp -r "$tmp_config" "$install_location/home/$username/.config/nixos/"
        sudo cp "${public_key}" "$install_location/home/$username/.ssh/id_ed25519.pub"
        sudo cp "${private_key}" "$install_location/home/$username/.ssh/id_ed25519"

        sudo chmod 644 "$install_location/home/$username/.ssh/id_ed25519.pub"
        sudo chmod 600 "$install_location/home/$username/.ssh/id_ed25519"

        sudo nixos-install --root "$install_location" --flake "$tmp_config#$hostname" --no-root-passwd

        cd $install_location/home/$username/.config/nixos
        git init
        git add -A
        git commit -m "temp: preserve local state"
        git remote add origin git@github.com:Rayzeq/nixos-config.git
        git fetch origin
        git reset --mixed origin/master
        git branch --set-upstream-to=origin/master

        sudo nixos-enter --root "$install_location" --command "chown -R $username:users /home/$username/.ssh /home/$username/.config"
      ''
    )
  ];
}
