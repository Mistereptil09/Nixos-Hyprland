{ config, lib, pkgs, profiles, ... }:

{
  # Host-specific configuration
  networking.hostName = "hyprland-laptop";
  
  # Any host-specific overrides
  services.xserver.displayManager.defaultSession = "hyprland";
  
  # Host-specific packages
  environment.systemPackages = with pkgs; [
    # Add any packages specific to this host
  ];
  
  # Set user-specific hardware access
  users.users.antonio.extraGroups = [ "input" ];
}
