{ config, lib, pkgs, homeProfiles, username, ... }:

{
  # Explicitly import home profiles
  imports = [
    # Import the minimal home profile
    homeProfiles.minimal
    
    # Add more profiles as needed
    # homeProfiles.development
    # homeProfiles.gaming
  ];

  # Host-specific home configuration
  home.username = username;
  home.homeDirectory = "/home/${username}";

  # Any host-specific home overrides can go here
  home.packages = with pkgs; [
    # Add any additional host-specific user packages
  ];

  # User-specific configuration
  programs.git = {
    # Uncomment and customize:
    # userName = "Your Name";
    # userEmail = "your.email@example.com";
  };
}
