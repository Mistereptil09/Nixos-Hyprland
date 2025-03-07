{ config, lib, pkgs, ... }:

{
  # User-level utility packages and configuration
  home.packages = with pkgs; [
    # Clipboard and screenshot utilities
    wl-clipboard        # Clipboard utilities for Wayland
    cliphist            # Clipboard history manager
    
    # Theming and configuration tools
    nwg-look            # GTK settings editor
    qt5ct               # Qt5 configuration tool
    lxappearance        # GTK theme switcher
    
    # Wayland-specific utilities
    wlsunset            # Gamma adjustments for Wayland (night light)
    
    # File and archive management
    file                # Determine file type
    unzip               # Extract .zip archives
    p7zip               # Extract various archive formats
    
    # System monitoring (user-friendly interfaces)
    bottom              # Alternative to htop with more visual features
    iotop               # I/O monitoring
    
    # Terminal enhancements
    starship            # Customizable shell prompt
    zoxide              # Smarter cd command
    
    # Additional user utilities
    xarchiver           # Archive manager
    gnome.gnome-calculator # Calculator
    gnome.eog           # Image viewer
  ];
  
  # Configure essential XDG directories
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };
  
  # Configure preferred applications
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "image/png" = "eog.desktop";
      "image/jpeg" = "eog.desktop";
      "application/zip" = "xarchiver.desktop";
      "application/x-compressed-tar" = "xarchiver.desktop";
    };
  };
  
  # Terminal tools configuration
  programs = {
    # Improved file listing
    exa = {
      enable = true;
      enableAliases = true; # Set up ls aliases automatically
    };
    
    # Improved cat
    bat = {
      enable = true;
      config = {
        theme = "TwoDark";
        pager = "less -FR";
      };
    };
    
    # Improved find
    fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "fd --type f";
    };
  };
}
