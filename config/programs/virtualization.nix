{ pkgs, ... }: {
  system = {
    virtualisation.libvirtd = {
      enable = true;
      qemu.vhostUserPackages = [ pkgs.virtiofsd ];
    };
    programs.virt-manager.enable = true;
    systemd.tmpfiles.rules = [ "L+ /var/lib/qemu/firmware - - - - ${pkgs.qemu}/share/qemu/firmware" ];
  };
  user.extraGroups = [ "libvirtd" "kvm" ];
}
