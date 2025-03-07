{ config, lib, pkgs, ... }:

{
  # User applications
  home.packages = with pkgs; [
    # Browsers
    firefox
    thunderbird
    
    # Communication
    discord
    slack
    
    # Office and productivity
    libreoffice
    zathura
    
    # File management
    thunar
    xfce.thunar-archive-plugin
    
    # Media
    mpv
    spotify
    
    # System monitoring
    btop
    
    # Additional tools moved from system level
    # keepassxc         # Password manager with browser integration
  ];
  
  # Terminal configuration
  programs.kitty = {
    enable = true;
    theme = "Tokyo Night";
    font = {
      name = "JetBrains Mono";
      size = 11;
    };
    settings = {
      confirm_os_window_close = 0;
    };
  };
  
  # Configure file associations
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "application/pdf" = "org.pwmt.zathura.desktop";
    };
  };
}
