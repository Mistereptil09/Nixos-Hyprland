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
