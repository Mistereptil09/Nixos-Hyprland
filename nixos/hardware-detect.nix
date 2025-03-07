{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ 
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Auto-detect CPU
  hardware.cpu = {
    intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };

  # Auto-detect if running in a VM
  virtualisation.vmware.guest.enable = lib.mkDefault (
    builtins.pathExists "/dev/vmware_balloons"
  );
  virtualisation.virtualbox.guest.enable = lib.mkDefault (
    builtins.pathExists "/dev/vboxguest"
  );

  # Enable firmware with a wide range of support
  hardware.enableRedistributableFirmware = lib.mkDefault true;
  
  # Enable kernel modules for commonly used hardware
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" "kvm-amd" ];
  boot.extraModulePackages = [ ];
}
