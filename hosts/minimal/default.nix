{ config, lib, pkgs, ... }:

{
  # Import minimal profile
  imports = [
    ../../modules/profiles/nixos/minimal.nix
  ];

  # Host-specific configuration
  networking.hostName = "nixos-minimal";

  # System settings
  system.stateVersion = "23.11"; # Update to match your NixOS version

  # Any host-specific overrides can go here
  environment.systemPackages = with pkgs; [
    # Add any additional host-specific packages
  ];

  # Customize minimal installation if needed
  # For example, you might want to enable additional services
  services = {
    # Add any host-specific services
  };

  # Host-specific module customization
  modules = {
    # Enable/disable specific modules as needed
  };
}
