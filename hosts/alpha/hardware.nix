{ config, lib, modulesPath, ... }: {
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usbhid" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/4ba2daf8-6cf6-43d2-b270-e0b06819c29a";
    fsType = "ext4";
  };

  fileSystems."/nix/store" = {
    device = "/nix/store";
    fsType = "none";
    options = [ "bind" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/D309-B1E9";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  fileSystems."/mnt/Storage" = {
    device = "/dev/disk/by-uuid/e3192cf9-7054-4b8e-8edc-6d97a5bc2d80";
    fsType = "ext4";
  };

  swapDevices = [{ device = "/dev/disk/by-uuid/b1a866f9-31ee-4592-9b75-32bd6f7666b6"; }];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
