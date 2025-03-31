{ config, lib, pkgs, modulesPath, ... }:

let
  isPlaceholder = true; # Set this to false after properly configuring your hardware
  errorMsg = ''
    ⚠️ ERROR: You need to generate a proper hardware-configuration.nix file!
    
    Please do one of the following:
    1. Run 'sudo nixos-generate-config' on your system and copy the generated
       hardware-configuration.nix to this file
    2. Or manually configure the hardware settings and set isPlaceholder = false
    
    This file contains PLACEHOLDER values that will NOT work on a real system.
  '';
in
{
  imports = 
    if isPlaceholder 
    then throw errorMsg
    else [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # Let the system detect your hardware
  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "sr_mod" "virtio_blk" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  # PLACEHOLDER: Replace this with your actual filesystem configuration
  fileSystems."/" = {
    device = "/dev/sda1";  # Adjust to match your system
    fsType = "ext4";
  };

  # PLACEHOLDER: Use a proper EFI system partition 
  fileSystems."/boot" = {
    device = "/dev/sda2";  # Adjust to match your system
    fsType = "vfat";
  };

  swapDevices = [ ];
}
