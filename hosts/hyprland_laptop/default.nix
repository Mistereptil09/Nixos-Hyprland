{ config, lib, pkgs, profiles, currentUsername, ... }:

{
  # Host-specific configuration
  networking.hostName = "hyprland-laptop";
  
  # Any host-specific overrides
  services.xserver.displayManager.defaultSession = "hyprland";
  
  # Host-specific packages
  environment.systemPackages = with pkgs; [
    # Add any packages specific to this host
  ];
  
  # Set user-specific hardware access - use the dynamic username
  users.users.${currentUsername}.extraGroups = [ "input" ];
}
