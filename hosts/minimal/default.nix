{ lib, pkgs, ... }:

{
  # Explicitly import profiles and hardware configuration
  imports = [
    # Include hardware-configuration.nix which will have your actual filesystem config
    ./hardware-configuration.nix
    
    # Import the minimal system profile
    ../../modules/core/boot
  ];
  
  # Enable the boot module
  core.boot.enable = true;
  
  # Host-specific configuration
  networking.hostName = "nixos-minimal";

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
