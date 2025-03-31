{ lib, pkgs, ... }:

{
  # Explicitly import profiles right in the host file
  imports = [
    # Import the minimal system profile
    ../../modules/core/boot
    
    # You could add other profiles directly
    # nixosProfiles.base
    # nixosProfiles.desktop
  ];
  
  # Enable the boot module
  core.boot.enable = true;
  
  # Host-specific configuration
  networking.hostName = "nixos-minimal";

  # Define your root filesystem - ADJUST THIS FOR YOUR SYSTEM!
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";  # Use the correct device for your system
    fsType = "ext4";  # Use the correct filesystem type
  };
  
  # You may also need to define /boot if using a separate boot partition
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";  # Use the correct device for your system
    fsType = "vfat";  # Usually vfat for EFI System Partition
  };

  # System settings
  system.stateVersion = "23.11";

  # Any host-specific overrides can go here
  environment.systemPackages = with pkgs; [
    # Add any additional host-specific packages
  ];

  # Customize minimal installation if needed
  services = {
    # Add any host-specific services
  };
}
