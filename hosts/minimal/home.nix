{ config, lib, pkgs, profiles, username, ... }:

{
  # Import minimal home profile
  imports = [
    (profiles.minimal)
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

  # Add any other host-specific home-manager settings
}
