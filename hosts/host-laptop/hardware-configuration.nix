# This file should contain the hardware-specific configuration
# Typically generated with 'nixos-generate-config'
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ 
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Here you would normally have your specific hardware configuration
  # Boot settings
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    # Add necessary kernel modules
    initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
    kernelModules = [ "kvm-intel" ];
  };

  # Filesystems
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  # Hardware settings
  hardware = {
    cpu.intel.updateMicrocode = true;
    opengl = {
      enable = true;
      driSupport = true;
    };
  };
}
